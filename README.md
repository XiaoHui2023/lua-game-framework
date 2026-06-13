# lua-game-framework

Lua 游戏通用框架，与 [lua-library](https://github.com/XiaoHui2023/lua-library) 配套使用。宿主侧通常将本仓库挂到 `script/lib/models/`，工具层挂到 `script/lib/utils/`。

## 模块

```text
camera/     # 相机与交互
chat/       # 聊天
core/       # 战斗、属性暴露、移动、管线、模板渲染
event/      # 事件与按键绑定
faction/    # 阵营
fx/         # 特效对象
game/       # 游戏会话
object/     # 通用游戏对象
player/     # 玩家与选单位
skill/      # 技能（主动/被动/目标/触发）
sound/      # 音效
state/      # 状态机
sync/       # 同步
terrain/    # 地形绘制与渲染
timer/      # 定时器
ui/         # UI 框架（frame、widget、behaviors）
unit/       # 单位与战斗/技能/放置等行为
factory.lua # 工厂入口
lighting.lua
mod.lua     # 模块加载与依赖排序
```

## 依赖

- `lua-library`：`utils.hook`、`utils.chain` 等
- 宿主环境（如 Y3 地图脚本）提供的引擎 API

## 加载

由运行入口把 `lib` 目录加入 `package.path`（与 `lua-library` 相同）：

```lua
local main_source = debug.getinfo(1, "S").source
local script_root = main_source:sub(1, 1) == "@" and main_source:sub(2) or main_source
script_root = script_root:match("^(.*)[/\\][^/\\]+$") or "."
package.path = script_root .. "/lib/?.lua;" .. script_root .. "/lib/?/init.lua;" .. package.path
```

业务脚本只写模块名（如 `require "models.game"`），不写本机绝对路径。
