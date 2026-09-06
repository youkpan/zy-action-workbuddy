# ZY Action Platform — WorkBuddy 独立技能包

把自研平台 **ZY Action Platform（AI 商业行动系统）** 接入腾讯 WorkBuddy 开放平台的 **独立技能（Skill）包**：用户在 WorkBuddy 中通过自然语言即可完成「下载安装与 DeepSeek Key 配置 → 连接登录 → 跨五个产品查数/跑自动化/查本体/搜情报/看部署」。发布到 WorkBuddy 技能市场。

> 说明：仓库 `products/workbuddy/connector/` 是另一条线的 WorkBuddy **连接器（MCP）** 包，与本目录的技能包相互独立、可分别上架，不要混淆。

## 目录结构

```
products/workbuddy/
├── README.md              本说明
├── CHANGELOG.md           版本变更（与 SKILL.md version 同步）
├── pack.bat               Win 打包脚本 → dist\zy-action-platform-v<版本>.zip
└── skills/
    └── zy-action-platform/           技能名 = 目录名
        ├── SKILL.md                  ★ 技能主文件（frontmatter + 指令正文，<200 行）
        ├── references/
        │   ├── api-spec.md           五产品 REST API 速查（命令↔端点↔curl/透传）
        │   └── examples.md           会话实录 + 失败话术（给 AI 对齐语气）
        └── scripts/
            └── zy_platform.py        唯一脚本，纯 Python 标准库（零依赖）
```

技能按 open.workbuddy.cn/docs/skill 规范组织（对应仓库 `action/wiki/dev/workbuddy-skill.md`）。

## 打包

```bat
pack.bat            :: 在 products/workbuddy 下运行；版本号自动取自 SKILL.md frontmatter
```

产物：`dist\zy-action-platform-v1.0.0.zip`（顶层即 `zy-action-platform/`，内含 SKILL.md）。校验：
`tar -tf dist\zy-action-platform-v1.0.0.zip`。要求体积 ≤3MB。若用 PowerShell 替代：
`Compress-Archive -Path skills\zy-action-platform -DestinationPath dist\zy-action-platform-vX.Y.Z.zip`。

## WorkBuddy 开放平台上架要点

1. 注册登录 `open.workbuddy.cn`，完成开发者主体认证（个人或企业）。
2. 创建**技能**能力 → 上传 zip（若控制台要求结构不同，改 `pack.bat` 的 `-C skills zy-action-platform` 那一段）。
3. 控制台核对并填写：名称/描述（zh/en）、使用示例、**category 分类**（`SKILL.md` 内暂填 `analytics`，官方枚举以控制台为准，选错可能触发资质审核）、作者。
4. 上传技能图标（本项目不含二进制图标，请在控制台补一张，建议透明背景小图标）。
5. 提交平台审核 → 通过后发布/分发。后续更新重新提交，通常 10~15 分钟同步。

## 提交前自检清单

- [ ] SKILL.md frontmatter 六个强制字段齐全：`description` / `description_zh` / `description_en` / `version` / `author`（`name` 建议同目录名）。
- [ ] `SKILL.md` ≤200 行；正文含安装与 config.yaml 配置引导、五产品命令速查、鉴权与安全规则。
- [ ] 脚本 `zy_platform.py` 可通过 `python -m py_compile`；冒烟命令见下。
- [ ] 未在 SKILL.md/脚本/示例中硬编码任何真实口令、token、API Key。
- [ ] `references/api-spec.md` 命令↔端点与实际代码一致（改后端接口后同步更新）。
- [ ] `version` 与 `CHANGELOG.md` 同步递增；打包 zip ≤3MB；`tar -tf` 顶层正确。
- [ ] （可选）`--list-commands` 输出 30 条命令均可被 SKILL 检索到。

## 本地冒烟（开发者）

```bash
cd skills/zy-action-platform/scripts
python zy_platform.py --list-commands
python zy_platform.py health --product gotham          # 本机 18083 有实例时
python zy_platform.py login --product gotham --username admin --password <口令>
python zy_platform.py search --product gotham --query "订单" --limit 3
python zy_platform.py request --product gotham --method GET --path=graph/stats
python zy_platform.py chat --product aip --query "各区域销售额 Top5"   # 需本机 AIP 在跑
```

> Windows Git Bash 注意：`--path`/`--data` 值勿以 `/` 开头（MSYS 会改写成盘符路径）；脚本已按"相对 API 根"设计。
