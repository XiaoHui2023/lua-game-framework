# ui

UI 框架模块，定义 UI 对象、创建流程、布局、事件和运行时能力。

- types 保存公共 UI 类型与配置契约。
- settings 保存默认尺寸、缩放、拖拽等参数。
- impl 按 core、frame、layout 拆分对象能力和创建 handler。

## 设计特性

### 对象模型

UI 对象由工厂创建，基础字段、响应式逻辑和事件监听在创建流程中装配。对象本体不直接持有模块级注册表。

### 分层实现

`impl/core/` 放通用对象能力，`impl/frame/` 放具体 frame 创建，`impl/layout/` 放容器布局。新增能力按家族落位。

### 运行时桥接

框架声明创建、设置尺寸、位置、文本、可见性等 API。runtime 注册 handler 后，框架对象才能驱动真实 UI。

## 目录

```text
apis.lua     # UI callback API
init.lua     # 模块门面与实现加载
layers.lua   # UI 层级管理
settings.lua # UI 默认参数
state.lua    # 模块状态
types.lua    # 公共 UI 类型
impl/        # UI 对象、frame 和 layout 实现
```
