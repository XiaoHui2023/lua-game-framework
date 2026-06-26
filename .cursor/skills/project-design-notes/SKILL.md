---
name: project-design-notes
description: 本仓库：Agent 当前有效的设计意图与硬性要求；变更见 project-changelog。
---

# 设计笔记（当前有效）

> 变更记录见 `.cursor/skills/project-changelog/SKILL.md`；矛盾以 changelog 最新条目为准。

## 设计意图

Lua 游戏通用框架：在宿主环境（如 Y3 地图脚本）上提供可复用的游戏层骨架，与 [lua-library](https://github.com/XiaoHui2023/lua-library) 分工——工具与数据结构放 `lua-library`，游戏流程、实体、场景、UI 桥接等放本仓库。

宿主侧通常将本仓库挂到 `script/lib/models/`；模块以 `require "framework.<name>"` 引用，工具以 `require "utils.<name>"` 引用。

当前顶层模块：`camera`、`chat`、`core`、`event`、`faction`、`fx`、`game`、`object`、`player`、`skill`、`sound`、`state`、`sync`、`terrain`、`timer`、`ui`、`unit`，以及根级 `factory.lua`、`mod.lua`、`lighting.lua`。

## 硬性要求

- 通用工具函数不重复实现，优先 `require` `lua-library` 对应模块。
- 运行入口只依赖 `package.path` 解析模块，业务脚本不写本机绝对路径。
- 相对 `require` 使用点号模块路径；跨父目录用 `require "..apis"`，禁止用 `require "../apis"` 这类文件路径斜杠。
- 当前文件新建或注册并返回的模块表统一命名为 `M`；导入其他模块时不用 `M`，按语义使用下划线小写别名。
- 用户向文档分工：根 `README.md` 写框架定位与加载方式；各子模块 `README.md` 写该模块用法；设计口径不写进源码长注释。
- 每个 `framework/*` 顶层子模块都必须有自己的 `README.md`；新增、重命名或拆分子模块时，同轮补齐或迁移模块 README，并同步根 `README.md` 的模块索引。
- Agent 三件套（预加载、设计笔记、changelog）放在 `.cursor/skills/`；通用规范在 `~/.cursor/skills/`。
- 子模块文件按职责命名，禁止新增泛名 `base.lua`、`config.lua`、`api.lua`：`init.lua` 承载模块公开门面、枚举、非 callback 契约和加载顺序；`state.lua` 承载模块级可变状态，且只能使用普通 Lua 值，不能用 reactive ref/event/semaphore；`settings.lua` 承载框架默认值和可覆盖开关；`types.lua` 承载较大的 EmmyLua 类型声明；`apis.lua` 仅承载 callback.api 声明；`impl/` 放引擎无关 callback handler；引擎外部能力由 `runtime/framework/*` 注册 callback 实现。
- 发现历史 `base.lua` 被当作模块共享表时，必须迁移为 `init.lua` 创建总表 `M` 并组装子模块；类型声明放 `types.lua`，模块内共享可变值放 `state.lua`，稳定默认值和可覆盖常量放 `settings.lua`，callback 契约放 `apis.lua`。子模块需要扩展总表时 require 公开模块名并依赖 `init.lua` 预先写入 `package.loaded[...] = M`，不得继续新增或传播 `.base` 依赖。

## 备忘与待定

## Framework 模块收口

- `init.lua` 只做模块纲要管理：例化并暴露 `apis`、`state`、`settings`，安排必要加载顺序；不要在 `init.lua` 里平铺大量 `state` / `settings` 字段代理。
- 外部业务应显式调用 `module.apis`、读取 `module.state`、使用 `module.settings`；不要为了少写参数在框架入口增加 `reset`、`scroll`、`set_*` 这类语法糖门面。
- `apis.lua` 的模块字段类型写成 `callback.api`；回调 payload 单独声明为 `---@class <module>.api.<Name>: callback.instance`，handler 参数用该 payload 类型标注。
- `apis.lua` 与 `settings.lua` 的公开 `---@field` 必须在类型后写中文语义说明；callback payload 字段要说明用途、单位和可选性，禁止只写类型。
- `impl` 统一使用 `impl/` 目录和 `impl/init.lua` 聚合；禁止继续新增或保留顶层 `impl.lua`。

- Runtime dependency injection rule: host/engine callable capabilities for `framework/*` must be declared in `framework/<module>/apis.lua` and implemented by `runtime/framework/<module>.lua` registering `module.apis` handlers. Runtime code must not replace framework facade functions. One-off runtime handlers are registered inline, and each registration has a short Chinese responsibility comment.
- UI impl directory rule: `framework/ui/init.lua` only loads `impl`; UI implementation families live under `framework/ui/impl/`. Put base UI object wiring and attachable capabilities such as `create_anchor`, `object`, `reactive_fields`, `reactive_logic`, `anchor`, `event`, `position`, `size`, `visible`, `drag`, `snap`, and `text` under `impl/core/`; put frame creation handlers under `impl/frame/`; put container and slot layout handlers under `impl/layout/`. Avoid leaving implementation files directly under `framework/ui/impl/`, and do not name the grouping directory `object`.
- Directory move rule: when moving `framework/<module>/<name>.lua` into `framework/<module>/impl/<name>.lua` and flattening `framework/<module>/impl/<name>/`, verify all three facts with literal paths before reporting success: the root file no longer exists, the target `impl/<name>.lua` exists, and the old `impl/<name>/` directory no longer exists. On Windows, use `Test-Path -LiteralPath` because `Test-Path path\object` can match `object.lua` and hide a failed directory cleanup.

## 备忘与待定（原记录）

- 首批模块划分（场景、实体、输入、存档等）待后续决议。
- 与 `lua-library` 的版本/兼容约定待定。
