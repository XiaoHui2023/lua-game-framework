# event

事件模块，统一按键、同步和宿主事件接入的框架侧契约。

- `apis.lua` 声明事件监听与分发能力。
- `types.lua` 放事件 payload 与枚举类型。
- `impl/` 注册引擎无关的事件组合逻辑。

## 设计特性

### 抽象事件

框架只面对 callback API 和事件类型，不直接依赖 Y3 事件对象。运行时把宿主事件翻译成框架事件。

### 实现拆分

按键绑定和同步事件分别放入 `impl/`。新增事件族时按职责建文件，不把所有 handler 堆进入口。

## 目录

```text
apis.lua          # 事件 callback API
init.lua          # 模块门面
settings.lua      # 事件默认参数
types.lua         # 事件类型声明
impl/init.lua     # 实现聚合
impl/key_binding.lua # 按键绑定实现
impl/sync.lua     # 同步事件实现
```
