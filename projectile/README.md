# projectile

投射物模块，封装投射物对象、默认参数和运行时能力声明。

- 投射物对象保存运动、碰撞和外观状态。
- behaviors 拆分外观、碰撞和位置更新。
- 特效句柄到投射物对象的映射由模块集中维护。

## 设计特性

### 对象生命周期

投射物作为对象创建、更新和销毁。命中、超时、目标丢失等规则可以围绕对象生命周期注册。

### 行为组合

外观、碰撞和放置行为分文件实现。新增投射物能力时优先作为行为扩展，而不是把逻辑堆进对象文件。

### 运行时接入

创建特效、移动句柄、销毁表现等能力通过 API 声明。框架层不直接调用引擎。

## 目录

```text
apis.lua               # 投射物 callback API
init.lua               # 模块门面与对象映射
object.lua             # 投射物对象
settings.lua           # 投射物默认参数
behaviors/appearance.lua # 外观行为
behaviors/collision.lua  # 碰撞行为
behaviors/placement.lua  # 放置与移动行为
behaviors/init.lua       # 行为聚合
```
