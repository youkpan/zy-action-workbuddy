---
name: zy-action-platform
description: 连接本机 ZY Action Platform（AI 数据智能操作系统）。可自然语言查数、查看并运行自动化工作流、浏览数据源。包含本地安装/配置/取 Client Key 指引。
---

# ZY Action Platform（ZY 行动平台）

通过本连接器，WorkBuddy 会调用你**本机/私有网络部署的 ZY Action Platform** 实例。连接后即可用自然语言：
- 查数据（NLQ 智能查数：自然语言 → SQL → 结果/图表，支持 RLS/CLS 权限）；
- 查看与运行自动化工作流、查询执行记录；
- 浏览已接入的数据源。

> 数据始终留在你自己的实例内执行；连接凭证（Client Key）只保存在本机 `~/.workbuddy`，不经过云端。

## 一、下载与安装 ZY Action Platform（如尚未安装）

1. 打开下载页：`https://zyinfo.pro/action/`（产品介绍、文档）。
2. 下载安装包：`https://zyinfo.pro/files/ZY-Action-Platform.rar`，解压到任意本地目录。
3. 配置：把目录下的 `config.yaml.example` **复制一份并重命名为 `config.yaml`**（与 `start-aip.bat` 同级）。
4. 填写 DeepSeek key：编辑 `config.yaml`，在 `llm.api_keys` 下填 `deepseek: "sk-你的DeepSeek_API_Key"`（如需其它模型也可填 `llm.api_keys.dashscope` 等；或把 `.env.example` 复制为 `.env` 填入 `DEEPSEEK_API_KEY`）。请同时确认 `security.secret_key`、`database` 等项有合理值。
5. 启动：双击 `start-aip.bat`（AIP 后端，默认 :18080）。看到日志 `AIP server listening` 即就绪。

## 二、开启 WorkBuddy 接入并取 Client Key

ZY Action Platform 默认已开启 WorkBuddy 接入（`config.yaml` 中 `workbuddy.enabled: true`；不需要可改 `false`）。

- `workbuddy.client_key` 若留空，AIP 启动时会**自动生成 `sk_live_xxxxxxxx...` 并写回 config.yaml** —— 直接打开 `config.yaml` 查看 `workbuddy.client_key` 即可。
- 建议为执行账号单独配置：`workbuddy.as_user`（默认 `admin`）会作为调用工具时的平台用户身份，请按最小权限原则使用。
- 云端 Hub **默认开放注册**：无需把 client_key 预先登记，任意非空 client_key（含自动生成的 `sk_live_*`）即可注册并创建连接，key 即实例唯一连接凭证。同一 key 不要给多台实例共用（后注册者会顶替先注册者）。确认本机 AIP 已启动且网络能到 Hub（AIP 未连上 Hub 不影响平台其它功能，它每 20 分钟自动重连一次）。

在 WorkBuddy 里安装/连接本连接器时，把 `ZY_CLIENT_KEY` 填成上面 config.yaml 中的 `workbuddy.client_key` 值即可。

### 进阶：本机直连调试（可选）

WorkBuddy 桌面端若支持手动添加 MCP Server，可直连本机 `http://127.0.0.1:18085/mcp`（需 `workbuddy.local_sse: true`，AIP 已启动）。此方式不依赖云端 Hub，仅用于本机调试。

## 三、可用工具与参数

| 工具 | 作用 | 必填参数 | 可选参数 |
| --- | --- | --- | --- |
| `nlq_chat` | 自然语言查数：问一句 → 意图识别/Text2SQL → 返回结果与可视化 | `query`（≤2000 字符） | — |
| `workflow_list` | 列出自动化工作流 | — | `page`(≥1 默认1)、`page_size`(1~100 默认20) |
| `workflow_run` | **运行一个工作流**（执行类，先与用户确认再调用） | `workflow_id` | `params`(object，覆盖全局变量) |
| `workflow_executions` | 查询工作流执行记录 | — | `workflow_id`(空=全部)、`page`、`page_size` |
| `workflow_execution_detail` | 查看某次执行详情 | `execution_id` | — |
| `datasource_list` | 浏览已接入的数据源（只读，仅返回 id/name/type/status） | — | `skip`(≥0 默认0)、`limit`(1~200 默认100) |

- 参数类型：`workflow_id`/`execution_id`/`query` 为字符串；`page`/`page_size`/`skip`/`limit` 为整数；`params` 为对象。
- 返回为 JSON 文本（工具结果块），其中可能包含查询列/行、SQL、图表 DSL 等；向用户呈现时优先给出易读的总结。

## 四、典型用法示例

- 查数：`帮我查一下上个月的总销售额是多少` → 调用 `nlq_chat`。
- 看工作流：`平台上都有哪些自动化工作流？` → `workflow_list`。
- 跑工作流：`运行一遍「周报自动生成」工作流吧` → 先 `workflow_list` 拿到 workflow_id，再确认后 `workflow_run`。
- 查执行：`最近一次周报工作流跑成功了吗` → `workflow_executions` + `workflow_execution_detail`。
- 看数据源：`现在接入了哪些数据库` → `datasource_list`。

## 五、错误排查

| 现象 | 原因与处理 |
| --- | --- |
| 401 | 未提供 `ZY_CLIENT_KEY` 或格式不对 → 在连接设置里重新填写。 |
| 403 | 仅 Hub 开启白名单收紧模式且该 key 未登记时出现 → 联系平台管理员在 Hub `clients` 加入你的 client_key。 |
| 502 / 实例离线 / 超时 | 本地 AIP 未启动、未连上 Hub，或请求超时 → 确认本机 `start-aip.bat` 已运行、`workbuddy.client_key` 与连接器填的一致；可稍等 AIP 下一次 20 分钟重连后重试。 |
| 查数被拒答 / 无数据源 | 该 as_user 无对应库表权限，或实例未接入数据源 → 在平台里配置数据源/权限后重试。 |

## 六、安全提示

- `workflow_run` 会真实触发执行，调用前请向用户确认。
- 建议 `workbuddy.as_user` 使用专用低权限账号，而非 admin。
- Client Key 是实例级凭证，仅告知其所有者；不要在对话或日志中完整输出。
- 凭证仅保存在用户本机；远程 Hub 只做转发，不落地业务数据。
