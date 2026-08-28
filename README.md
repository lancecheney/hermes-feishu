# hermes-feishu

> A Feishu (Lark)-optimized build of [hermes-agent](https://github.com/NousResearch/hermes-agent). · [中文](README.zh-CN.md)

This repo tracks upstream `main`, **pre-merges Feishu-related fix PRs that upstream has not accepted yet**, and periodically syncs upstream `main`.

> ⚠️ **Stability**
>
> Contains patches not fully reviewed upstream — **may be unstable**. If that matters, use upstream [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) directly.

## Pre-merged fixes

| Upstream PR | Description |
|---|---|
| [#37847](https://github.com/NousResearch/hermes-agent/pull/37847) | Feishu approval resolver authorization |
| [#18188](https://github.com/NousResearch/hermes-agent/pull/18188) | gateway runtime footer metadata |
| [#18131](https://github.com/NousResearch/hermes-agent/pull/18131) | build Feishu tool client from env credentials |

## Usage

```bash
git clone https://github.com/lancecheney/hermes-feishu.git
cd hermes-feishu
# install & run hermes as usual — the default branch `main` already includes the fixes
```

### Update

`main` is the Feishu-optimized build. Update via the gateway-aware command:

```bash
hermes update --gateway
```

or the `/update` slash command inside Feishu (which runs `--gateway` internally).

### Data safety

This fork only changes code — it does **not** touch your existing Hermes data (config, sessions, memory, skills, cron jobs). Still, before switching from the official build, back up your Hermes home first:

```bash
cp -r ~/.hermes ~/.hermes.bak
```

## Sync strategy (maintainer)

- `main`: default branch = upstream `main` + the fixes above
- `upstream-main`: pristine mirror of upstream `main`
- each upstream PR maps to a `pr/<number>` branch

See [FEISHU-FORK.md](FEISHU-FORK.md). Upstream docs: [hermes-agent docs](https://hermes-agent.nousresearch.com/docs/).
