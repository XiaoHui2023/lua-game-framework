---
name: project-changelog
description: 本仓库：按时间记录要求与决议；最新在上；矛盾以最新为准。
---

# 变更记录

（规则见 `~/.cursor/skills/agent-project-changelog/SKILL.md`。）

## 2026-06-25

- **要求**：每个 `framework/*` 顶层子模块都必须有自己的 `README.md`；新增、重命名或拆分子模块时，同轮补齐或迁移模块 README，并同步根 README 模块索引。
- **补充**：为当前所有顶层 framework 模块补齐模块 README，并更新根 README 模块列表。

## 2026-06-19

- **Requirement**: when changing `framework/ui`, evaluate framework object state and runtime Y3 state together. Parent changes must update logical `parent`/`children`, layout membership, runtime `SET_PARENT`, and outline shadow parent handles. Also scan UI Lua files for `-- ... code` comment-corruption before claiming syntax/layout correctness.

- **要求**：`framework/*` callback API 必须显式通过 `framework.<module>.apis` 订阅或触发；禁止把 `apis.lua` 字段平铺到 `framework.<module>` 门面上形成 `module.ON_*`、`module.SET_*` 等语法糖。`framework` 子模块统一使用 `apis.lua` + `impl/`，禁止继续保留 `base.lua`、`api.lua`、`config.lua`、`bindings.lua`、顶层 `impl.lua` 旧结构文件。

## 2026-06-18

- **Requirement**: host/engine callable capabilities for `framework/*` must be declared in `framework/<module>/apis.lua` and implemented by registering `module.apis` handlers in `runtime/framework/<module>.lua`; do not replace framework facade functions. One-off runtime handlers stay inline as `apis.X(function(api) ... end)`, and each registration needs a short responsibility comment.

## 2026-06-13

- **要求**：`apis.lua` 与 `settings.lua` 的公开 `---@field` 必须在类型后写中文语义说明；callback payload 字段要说明用途、单位和可选性，禁止只写类型。
- **补充**：补齐 `camera/apis.lua` 与 `camera/settings.lua` 的公开 API、payload、默认设置字段注释。

- **决议**：框架子模块 `init.lua` 只做纲要管理与例化，不平铺大量 `state` / `settings` 字段代理；外部业务显式调用 `module.apis`、读取 `module.state`、使用 `module.settings`，不在框架入口增加 `reset`、`scroll`、`set_*` 这类语法糖门面；`apis.lua` 中 API 字段标为 `callback.api`，payload 类型继承 `callback.instance`；`impl` 代码很少时用单文件 `impl.lua`，不建 `impl/` 目录。

- **决议**：Lua 相对 `require` 使用点号模块路径，跨父目录写 `require "..xxx"`，禁止写 `require "../xxx"` 这类文件路径斜杠。
- **清理**：删除 `camera/interact.lua` 空壳转发文件；`camera/impl/init.lua` 的相对引用改为 `..apis`、`..state`、`..settings`。

- **决议**：框架子模块不再保留单独 `api.lua`；目录入口 `init.lua` 承载公开门面和加载顺序，`apis.lua` 专用于 callback API 声明。
- **迁移**：删除 `camera/api.lua`，其门面逻辑迁入 `camera/init.lua`。

- **决议**：框架子模块的模块级可变状态统一放入 `state.lua`，只使用普通 Lua 值；API/实现协作统一用 `lib.callback`，引擎外部能力在 `runtime/framework/*` 注册 callback 实现。
- **迁移**：`camera` 改为 `state.lua` + `apis.lua` + `impl/` + `runtime/framework/camera.lua` 的 callback 分层。

- **决议**：Lua 当前文件新建或注册并返回的模块表统一命名为 `M`，不再使用 `g` 作为模块表变量；导入其他模块时不用 `M`，按语义使用下划线小写别名。

- **决议**：框架子模块不再使用泛名 `base.lua`、`config.lua`、`api.lua`；按职责拆为 `init.lua`、`settings.lua`、`state.lua`、`types.lua`、`apis.lua`、`impl/`，其中 `apis.lua` 仅用于 callback.api 声明。
- **迁移**：`camera` 子模块改为 `init.lua` 门面 + `settings.lua` 结构。

- **决议**：仓库按 Agent 三件套初始化；远程仓库为 `https://github.com/XiaoHui2023/lua-game-framework`。
- **要求**：实质性工作前经 `project-preload-skills` 加载 design-notes 与 changelog。
- **决议**：框架与 `lua-library` 分工——工具库在 `lua-library`，游戏骨架在本仓库。
