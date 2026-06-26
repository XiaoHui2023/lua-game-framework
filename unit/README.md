# unit

单位模块，封装框架单位对象、单位映射和单位行为组合。

- 单位句柄到框架对象的映射由模块维护。
- object 保存单位基础生命周期。
- behaviors 拆分外观、属性、战斗、位置、技能和目标能力。

## 设计特性

### 对象映射

运行时或创建流程把引擎单位句柄绑定到框架单位对象。其他系统通过统一映射拿到框架对象，而不是直接操作句柄。

### 行为组合

单位能力按行为拆分。战斗系统只关心 combat，技能系统只关心 skill，目标选择只关心 target，避免对象文件无限增长。

### 移动类型

模块提供基础移动类型枚举。地面、空中和无移动类型可被投放、碰撞或目标规则读取。

## 目录

```text
apis.lua                # 单位 callback API
init.lua                # 单位门面、枚举和映射
object.lua              # 单位对象
settings.lua            # 单位默认参数
behaviors/appearance.lua # 外观行为
behaviors/attribute.lua  # 属性行为
behaviors/combat.lua     # 战斗行为
behaviors/placement.lua  # 位置行为
behaviors/skill.lua      # 技能行为
behaviors/target.lua     # 目标行为
behaviors/init.lua       # 行为聚合
```
