# hermes-feishu

> [hermes-agent](https://github.com/NousResearch/hermes-agent) 的飞书（Lark）优化分支。 · [English](README.md)

本仓库基于上游 `main`，**提前合入尚未被上游接受的飞书相关修复 PR**，并定期同步上游 `main`。

> ⚠️ **稳定性**
>
> 包含未经上游完整评审的补丁，**可能不稳定**。介意请直接用上游 [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)。

## 已提前合入的修复

| 上游 PR | 说明 |
|---|---|
| [#37847](https://github.com/NousResearch/hermes-agent/pull/37847) | 飞书 approval 鉴权解析 |
| [#18188](https://github.com/NousResearch/hermes-agent/pull/18188) | gateway runtime footer 元数据 |
| [#18131](https://github.com/NousResearch/hermes-agent/pull/18131) | 飞书 tool client 从 env 凭据构建 |

## 使用

```bash
git clone https://github.com/lancecheney/hermes-feishu.git
cd hermes-feishu
# 按正常方式安装运行 hermes —— 默认分支 main 已集成上述修复
```

### 更新

`main` 就是飞书优化版，所以标准的更新命令直接可用：

```bash
hermes update
```

如果是在飞书对话里更新，强烈建议改用 gateway 模式：

```bash
hermes update --gateway
```

或直接在飞书里用 `/update` 斜杠命令（内部就是 `--gateway` 模式）。

### 数据安全

本 fork 只改代码，**不会**动你已有的 Hermes 数据（配置、会话、记忆、技能、cron 任务）。不过从官方版切换前，建议先备份 Hermes 目录：

```bash
cp -r ~/.hermes ~/.hermes.bak
```

## 同步策略（维护者）

- `main`：默认分支 = 上游 `main` + 上述修复
- `upstream-main`：上游 `main` 的纯净镜像
- 每个上游 PR 对应一个 `pr/<编号>` 分支

详见 [FEISHU-FORK.md](FEISHU-FORK.md)。上游完整文档：[hermes-agent docs](https://hermes-agent.nousresearch.com/docs/)。
