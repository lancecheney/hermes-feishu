#!/usr/bin/env bash
# sync-upstream.sh — sync lancecheney/hermes-feishu with upstream NousResearch/hermes-agent
#
# Keeps `upstream-main` as a pristine mirror of upstream/main, rebases each pr/*
# branch and the `meta` branch (fork-specific files) on top of it, rebuilds the
# `main` integration branch (the Feishu-optimized build), then force-pushes.
# Run from anywhere inside the repo with a clean working tree.

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

# -- fail fast with a clear message if a previous sync was interrupted ----------
if [ -d "$repo_root/.git/rebase-merge" ] || [ -d "$repo_root/.git/rebase-apply" ]; then
  echo "error: a rebase is in progress — finish it first:" >&2
  echo "         git rebase --continue     (after resolving)" >&2
  echo "       or abort it:" >&2
  echo "         git rebase --abort" >&2
  exit 1
fi
if [ -f "$repo_root/.git/MERGE_HEAD" ]; then
  echo "error: a merge is in progress — finish it (git merge --continue) or abort (git merge --abort) first" >&2
  exit 1
fi
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "error: working tree is dirty — commit or stash first" >&2
  exit 1
fi

list_conflicts() {
  local unmerged
  unmerged="$(git diff --name-only --diff-filter=U 2>/dev/null || true)"
  if [ -n "$unmerged" ]; then
    echo "    conflicted files:" >&2
    echo "$unmerged" | sed 's/^/      /' >&2
  fi
}

echo "==> fetching upstream"
git fetch upstream

echo "==> advancing pristine upstream-main mirror"
git checkout -q upstream-main
git reset --hard upstream/main

refresh_pr_branch_from_github() {
  local branch=$1 number head_repo head_ref head_sha state row fetched_sha

  number="${branch#pr/}"
  if ! command -v gh >/dev/null 2>&1; then
    echo "error: gh is required to refresh $branch from GitHub" >&2
    return 1
  fi

  if ! row=$(gh api "repos/NousResearch/hermes-agent/pulls/$number" \
      --jq '[.state, .head.repo.full_name, .head.ref, .head.sha] | @tsv'); then
    echo "error: cannot read GitHub PR #$number" >&2
    return 1
  fi
  IFS=$'\t' read -r state head_repo head_ref head_sha <<<"$row"
  if [ "$state" != "open" ]; then
    echo "error: GitHub PR #$number is $state; refusing to refresh $branch" >&2
    return 1
  fi
  if [ -z "$head_repo" ] || [ -z "$head_ref" ] || [ -z "$head_sha" ]; then
    echo "error: GitHub PR #$number has incomplete head information" >&2
    return 1
  fi

  echo "    refreshing $branch from $head_repo:$head_ref ($head_sha)"
  if ! git fetch fork "+refs/heads/$head_ref:refs/remotes/fork/pr/$number" \
      >/tmp/sync-fetch-pr-$number.log 2>&1; then
    echo "error: cannot fetch GitHub head for PR #$number" >&2
    cat "/tmp/sync-fetch-pr-$number.log" >&2
    return 1
  fi
  fetched_sha="$(git rev-parse "refs/remotes/fork/pr/$number")"
  if [ "$fetched_sha" != "$head_sha" ]; then
    echo "error: fetched PR #$number SHA $fetched_sha differs from GitHub SHA $head_sha" >&2
    return 1
  fi

  # The GitHub PR head is authoritative. This intentionally discards stale
  # local copies of the same PR branch before the integration rebase.
  git reset --hard "refs/remotes/fork/pr/$number" >/dev/null
}

echo "==> rebasing pr/* branches onto upstream/main"
merged_branches=()
for b in $(git for-each-ref --format='%(refname:short)' refs/heads/pr/); do
  git checkout -q "$b"
  if ! refresh_pr_branch_from_github "$b"; then
    echo "error: could not refresh $b from GitHub" >&2
    exit 1
  fi
  if git rebase upstream/main >/tmp/sync-rebase.log 2>&1; then
    if [ -z "$(git rev-list upstream/main.."$b")" ]; then
      merged_branches+=("$b")
    else
      echo "    rebased $b"
    fi
  else
    echo "error: rebase conflict on $b" >&2
    list_conflicts
    echo "    last rebase output:" >&2
    tail -n 12 /tmp/sync-rebase.log | sed 's/^/      /' >&2
    echo "    resolve conflicts, then:  git add <files> && git rebase --continue" >&2
    echo "    or skip this branch:      git rebase --abort" >&2
    echo "    (after finishing, re-run this script)" >&2
    exit 1
  fi
done

echo "==> rebasing meta branch"
if git rev-parse --verify --quiet meta >/dev/null; then
  git checkout -q meta
  if git rebase upstream/main >/tmp/sync-rebase-meta.log 2>&1; then
    echo "    rebased meta"
  else
    echo "error: rebase conflict on meta" >&2
    list_conflicts
    tail -n 12 /tmp/sync-rebase-meta.log | sed 's/^/      /' >&2
    echo "    resolve conflicts, then:  git add <files> && git rebase --continue" >&2
    echo "    or skip:                  git rebase --abort" >&2
    exit 1
  fi
fi

echo "==> rebuilding main integration branch"
git checkout -q main
git reset --hard upstream/main
for b in $(git for-each-ref --format='%(refname:short)' refs/heads/pr/); do
  if ! git merge --no-edit "$b" >/tmp/sync-merge.log 2>&1; then
    echo "error: merge conflict integrating $b into main" >&2
    list_conflicts
    tail -n 12 /tmp/sync-merge.log | sed 's/^/      /' >&2
    echo "    resolve conflicts, then:  git add <files> && git merge --continue" >&2
    echo "    or abort:                 git merge --abort" >&2
    exit 1
  fi
done
if git rev-parse --verify --quiet meta >/dev/null; then
  if ! git merge --no-edit meta >/tmp/sync-merge-meta.log 2>&1; then
    echo "error: merge conflict integrating meta into main" >&2
    list_conflicts
    tail -n 12 /tmp/sync-merge-meta.log | sed 's/^/      /' >&2
    echo "    resolve conflicts, then:  git add <files> && git merge --continue" >&2
    echo "    or abort:                 git merge --abort" >&2
    exit 1
  fi
fi

echo "==> pushing"
git push origin upstream-main --force-with-lease
git push origin main --force-with-lease
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

git checkout -q main
echo ""
echo "done — main is at $(git rev-parse --short HEAD)"
