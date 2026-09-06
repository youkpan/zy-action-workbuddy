# ZY Action Platform WorkBuddy 技能包 变更记录

> 与 `skills/zy-action-platform/SKILL.md` 的 `version` 字段保持同步递增。

## v1.0.0（2026-09-06）

首版独立 WorkBuddy 技能包发布。

- **结构**：`skills/zy-action-platform/`（SKILL.md + references + scripts）标准技能包结构，zip 顶层为技能目录。
- **能力**：一个综合技能覆盖五产品 —— 安装引导与 DeepSeek Key 配置（config.yaml 为主）／健康检查／登录（双格式 token 解析）／AIP NLQ 查数 + 自动化工作流（列表/运行/状态/取消）／Foundry 数据源/数据集/本体/语义检索/指标/看板/报表／Gotham 搜索/图谱/实体/时空/报告／Apollo 期望状态/部署/漂移/bundle/agent＋`/docs` 自省／Swift 健康。
- **脚本**：`scripts/zy_platform.py` 纯 Python 标准库；精选子命令 + 通用 `request` 透传；token 缓存 `~/.workbuddy/zy_action_session.json`；退出码 0–5；Windows/Git Bash 兼容（`--path` 不带前导 `/`）。
- **文档自读**：SKILL 指导 AI 按用户提供安装目录 Read/Grep 随包 docs（README、API 接入及测试方法参考.txt、docs/manuals、api-demo）辅助精确调用。
- 不含真实密钥/口令；与仓库 `products/workbuddy/connector/`（P2 MCP 连接器，并行线）相互独立。
