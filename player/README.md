# player

玩家模块，管理玩家对象映射、玩家枚举和玩家相关 callback API。

- 按玩家 ID 读取框架玩家对象。
- 提供本地玩家、在线人类玩家等遍历入口。
- 鼠标控制和选中单位等默认行为放在 `impl/`。

## 设计特性

### 玩家映射

模块保存 ID 到玩家对象的映射。运行时创建或绑定玩家后，上层系统可以通过统一入口读取玩家。

### 异步边界

`async` 用于判断当前逻辑是否应在本地玩家之外跳过。输入、UI 和镜头逻辑可以复用同一判断。

### 默认行为

鼠标控制、选中单位等行为是框架默认实现，放在 `impl/` 并通过 callback API 与运行时能力协作。

## 目录

```text
apis.lua              # 玩家 callback API
init.lua              # 玩家门面、枚举和查询
settings.lua          # 玩家默认参数
impl/init.lua         # 实现聚合
impl/mouse_control.lua # 鼠标控制
impl/select_unit.lua  # 选中单位
```
