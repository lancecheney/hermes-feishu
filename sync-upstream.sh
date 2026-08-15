#!/usr/bin/env bash
# sync-upstream.sh — sync lancecheney/hermes-feishu with upstream NousResearch/hermes-agent
#
# Keeps `main` as a pristine mirror of upstream/main, rebases each pr/* branch and
# the `meta` branch (fork-specific files) on top of it, rebuilds the `feishu`
# integration branch, then force-pushes the result.
# Run from anywhere inside the repo with a clean working tree.

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "error: working tree is dirty — commit or stash first" >&2
  exit 1
fi

echo "==> fetching upstream"
git fetch upstream

echo "==> advancing pristine main mirror"
git checkout -q main
git reset --hard upstream/main

echo "==> rebasing pr/* branches onto upstream/main"
merged_branches=()
for b in $(git for-each-ref --format='%(refname:short)' refs/heads/pr/); do
  git checkout -q "$b"
  if git rebase upstream/main >/dev/null 2>&1; then
    if [ -z "$(git rev-list upstream/main.."$b")" ]; then
      merged_branches+=("$b")
    else
      echo "    rebased $b"
    fi
  else
    echo "error: rebase conflict on $b — resolve it, then re-run" >&2
    exit 1
  fi
done

echo "==> rebasing meta branch"
if git rev-parse --verify --quiet meta >/dev/null; then
  git checkout -q meta
  if git rebase upstream/main >/dev/null 2>&1; then
    echo "    rebased meta"
  else
    echo "error: rebase conflict on meta — resolve it, then re-run" >&2
    exit 1
  fi
fi

echo "==> rebuilding feishu integration branch"
git checkout -q feishu
git reset --hard upstream/main
for b in $(git for-each-ref --format='%(refname:short)' refs/heads/pr/); do
  git merge --no-edit "$b" >/dev/null 2>&1 || {
    echo "error: merge conflict integrating $b into feishu" >&2
    exit 1
  }
done
if git rev-parse --verify --quiet meta >/dev/null; then
  git merge --no-edit meta >/dev/null 2>&1 || {
    echo "error: merge conflict integrating meta into feishu" >&2
    exit 1
  }
fi

echo "==> pushing"
git push origin main --force-with-lease
git push origin feishu --force-with-lease
for b in $(git for-each-ref --format='%(refname:short)' refs/heads/pr/); do
  git push origin "$b" --force-with-lease
done
if git rev-parse --verify --quiet meta >/dev/null; then
  git push origin meta --force-with-lease
fi

echo ""
if [ ${#merged_branches[@]} -gt 0 ]; then
  echo "These pr/* branches have no commits beyond upstream/main (likely merged upstream):"
  for b in "${merged_branches[@]}"; do
    echo "  $b   (delete with: git branch -d $b && git push origin --delete $b)"
  done
else
  echo "No pr/* branches look fully merged upstream yet."
fi

echo ""
echo "Upstream PR status:"
for b in $(git for-each-ref --format='%(refname:short)' refs/heads/pr/); do
  n="${b#pr/}"
  st=$(gh pr view "$n" --repo NousResearch/hermes-agent --json state,mergedAt -q 'if .mergedAt != null then "MERGED " + .mergedAt else .state end' 2>/dev/null || echo "n/a")
  printf '  %-12s PR #%s : %s\n' "$b" "$n" "$st"
done

git checkout -q feishu
echo ""
echo "done — feishu is at $(git rev-parse --short HEAD)"
