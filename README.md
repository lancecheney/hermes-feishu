# hermes-feishu

> [hermes-agent](https://github.com/NousResearch/hermes-agent) 的飞书（Lark）优化分支
> · A Feishu (Lark)-optimized build of [hermes-agent](https://github.com/NousResearch/hermes-agent)

本仓库基于上游 `main`，**提前合入尚未被上游接受的飞书相关修复 PR**，并定期同步上游 `main`。
This repo tracks upstream `main`, **pre-merges Feishu-related fix PRs that upstream has not accepted yet**, and periodically syncs upstream `main`.

> ⚠️ **稳定性 / Stability**
>
> 包含未经上游完整评审的补丁，**可能不稳定**。介意请直接用上游 [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)。
> Contains patches not fully reviewed upstream — **may be unstable**. If that matters, use upstream [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) directly.

## 已提前合入的修复 / Pre-merged fixes

| 上游 PR / Upstream PR | 说明 / Description |
|---|---|
| [#37847](https://github.com/NousResearch/hermes-agent/pull/37847) | 飞书 approval 鉴权解析 / Feishu approval resolver authorization |
| [#18188](https://github.com/NousResearch/hermes-agent/pull/18188) | gateway runtime footer 元数据 / gateway runtime footer metadata |
| [#18131](https://github.com/NousResearch/hermes-agent/pull/18131) | 飞书 tool client 从 env 凭据构建 / build Feishu tool client from env credentials |

## 使用 / Usage

```bash
git clone https://github.com/lancecheney/hermes-feishu.git
# 默认分支 main 即已集成上述修复
# default branch `main` already includes the fixes above
```

## 同步策略 / Sync strategy

- `main`：默认分支 = 上游 `main` + 上述修复（飞书优化版）/ default branch = upstream `main` + the fixes above
- `upstream-main`：上游 `main` 的纯净镜像 / pristine mirror of upstream `main`
- 每个上游 PR 对应一个 `pr/<编号>` 分支 / each upstream PR maps to a `pr/<number>` branch

详见 / See [FEISHU-FORK.md](FEISHU-FORK.md)。上游完整文档 / Upstream docs: [hermes-agent docs](https://hermes-agent.nousresearch.com/docs/)。
