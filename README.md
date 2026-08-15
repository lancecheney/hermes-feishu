# hermes-feishu

> [hermes-agent](https://github.com/NousResearch/hermes-agent) 的飞书（Lark）优化分支。

本仓库基于上游 [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) 的 `main`，**提前合入了一些尚未被上游接受的飞书相关修复 PR**，并**定期同步上游 `main`**。适合想尽早用上飞书相关修复、又不想等上游合并的用户。

> ⚠️ **稳定性说明**
>
> 本仓库包含尚未经过上游完整评审的补丁，**可能不稳定**。如果你介意稳定性，请直接使用上游 [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)。

## 已提前合入的修复

| 上游 PR | 说明 |
|---|---|
| [#37847](https://github.com/NousResearch/hermes-agent/pull/37847) | 飞书 approval 鉴权解析 |
| [#18188](https://github.com/NousResearch/hermes-agent/pull/18188) | gateway runtime footer 元数据 |
| [#18131](https://github.com/NousResearch/hermes-agent/pull/18131) | 飞书 tool client 从 env 凭据构建 |

## 使用

```bash
git clone https://github.com/lancecheney/hermes-feishu.git
# 默认分支 feishu 即已集成上述修复
```

## 同步策略

- `main`：上游 `main` 的纯净镜像，定期 reset 到上游最新。
- `feishu`：默认分支 = 上游 `main` + 上述修复。
- 每个上游 PR 对应一个 `pr/<编号>` 分支，便于上游合并后单独移除。

完整同步说明见 [FEISHU-FORK.md](FEISHU-FORK.md)。上游完整文档见 [hermes-agent docs](https://hermes-agent.nousresearch.com/docs/)。
