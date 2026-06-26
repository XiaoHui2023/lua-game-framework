# camera

摄像机框架模块，声明摄像机能力、默认参数和模块状态。

- `apis.lua` 声明摄像机对外 callback 能力。
- `settings.lua` 放默认跟随、缩放或滚动参数。
- `state.lua` 保存模块级普通 Lua 状态。

## 设计特性

### API 驱动

摄像机动作通过 callback API 声明。运行时注册具体引擎实现，框架层只负责发出抽象请求。

### 状态集中

摄像机当前目标、模式或临时值放在 state 中。门面只暴露 `apis`、`settings`、`state`，避免散落字段。

## 目录

```text
apis.lua     # 摄像机 callback API
impl.lua     # 引擎无关默认处理
init.lua     # 模块门面
settings.lua # 默认摄像机参数
state.lua    # 模块状态
```
