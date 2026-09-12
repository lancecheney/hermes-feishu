# hermes-feishu

飞书优化版 hermes-agent。跟踪上游 [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) 的 `main`，并叠加 3 个尚未被上游合并的修复 PR。

## 分支结构

| 分支 | 作用 |
|---|---|
| `main` | **默认分支** = 上游 `main` + 3 个 `pr/*` + `meta`，**直接 clone 就是这个飞书优化版** |
| `upstream-main` | 上游 `main` 的纯净镜像，定期 reset 到 `upstream/main`，**不要手动提交** |
| `pr/37847` | 飞书 approval 鉴权修复（上游 PR #37847） |
| `pr/18188` | gateway runtime footer 元数据（上游 PR #18188） |
| `pr/18131` | 飞书 tool client 从 env 凭据构建（上游 PR #18131） |
| `meta` | fork 专属文件（`sync-upstream.sh`、`FEISHU-FORK.md`、`README.md`），同步时一并 rebase 与合入 |

## 使用

```bash
git clone https://github.com/lancecheney/hermes-feishu.git   # 默认分支 main 就是飞书优化版
# 或显式指定
git clone https://github.com/lancecheney/hermes-feishu.git -b main
```

## 更新（服务器上）

因为 `main` 就是飞书优化版，直接：

```bash
hermes update            # 默认更新 main，即飞书优化版
```

> 若 `hermes update` 弹出「是否把官方仓库加为 upstream remote」，选 **n** 即可（它会记住）。它检测到 `main` 有上游没有的提交时，会自动跳过上游同步、保留你的修复。

## 定期同步上游（在 fork 上）

```bash
./sync-upstream.sh
```

脚本做的事：

1. `git fetch upstream`（上游 = NousResearch/hermes-agent）
2. 把 `upstream-main` reset 到 `upstream/main`
3. 把每个 `pr/*` 分支 rebase 到新的 `upstream/main`
4. 重建 `main` = `upstream/main` + 所有 `pr/*` + `meta`，force-push

运行前保证工作区干净（无未提交改动）。

## 判断上游有没有合并我的 PR

同步后脚本会打印每个 `pr/*` 对应的上游 PR 状态。两个信号：

1. **`pr/*` 分支 rebase 后没有任何超出 `upstream/main` 的提交** → 该 PR 的改动已全部进入上游 main，可删掉对应分支：
   ```bash
   git branch -d pr/37847 && git push origin --delete pr/37847
   ```
2. 直接查 PR 状态确认：
   ```bash
   gh pr view 37847 --repo NousResearch/hermes-agent --json state,mergedAt,mergeCommit
   ```

> 注意：若上游用 squash merge，分支里的提交 hash 会变，rebase 后可能仍“有提交”。以 `gh pr view` 的 `mergedAt` 为准。

## 手动同步（不跑脚本时）

```bash
git fetch upstream
git checkout upstream-main && git reset --hard upstream/main && git push origin upstream-main --force-with-lease
git checkout pr/37847 && git rebase upstream/main
git checkout pr/18188 && git rebase upstream/main
git checkout pr/18131 && git rebase upstream/main
git checkout main && git reset --hard upstream/main
git merge --no-edit pr/37847 && git merge --no-edit pr/18188 && git merge --no-edit pr/18131
git merge --no-edit meta
git push origin main pr/37847 pr/18188 pr/18131 meta --force-with-lease
```
