---
name: project-design-notes
description: 本仓库：Agent 当前有效的设计意图与硬性要求；变更见 project-changelog。
---

# 设计笔记（当前有效）

> 变更记录见 `.cursor/skills/project-changelog/SKILL.md`；矛盾以 changelog 最新条目为准。

## 设计意图

Lua 游戏通用框架：在宿主环境（如 Y3 地图脚本）上提供可复用的游戏层骨架，与 [lua-library](https://github.com/XiaoHui2023/lua-library) 分工——工具与数据结构放 `lua-library`，游戏流程、实体、场景、UI 桥接等放本仓库。

宿主侧通常将本仓库挂到 `script/lib/models/`；模块以 `require "models.<name>"` 引用，工具以 `require "utils.<name>"` 引用。

当前顶层模块：`camera`、`chat`、`core`、`event`、`faction`、`fx`、`game`、`object`、`player`、`skill`、`sound`、`state`、`sync`、`terrain`、`timer`、`ui`、`unit`，以及根级 `factory.lua`、`mod.lua`、`lighting.lua`。

## 硬性要求

- 通用工具函数不重复实现，优先 `require` `lua-library` 对应模块。
- 运行入口只依赖 `package.path` 解析模块，业务脚本不写本机绝对路径。
- 用户向文档分工：根 `README.md` 写框架定位与加载方式；各子模块 `README.md` 写该模块用法；设计口径不写进源码长注释。
- Agent 三件套（预加载、设计笔记、changelog）放在 `.cursor/skills/`；通用规范在 `~/.cursor/skills/`。

## 备忘与待定

- 首批模块划分（场景、实体、输入、存档等）待后续决议。
- 与 `lua-library` 的版本/兼容约定待定。
