# skill

技能模块，提供主动技能、被动技能、触发、目标、动作和属性项的组合模型。

- 技能对象基于 reactive factory，字段随对象释放。
- stat、trigger、target、action 分别描述数值、触发、选取和执行。
- 主动与被动技能共享基础效果模型。

## 设计特性

### 组合对象

技能由多个小对象组合而成。触发器决定何时发生，目标器决定作用对象，动作负责执行效果。

### 被动效果

被动效果在挂入技能时触发 attach，技能释放时触发 detach。装备、光环、状态类能力可以复用该生命周期。

### 主动释放

主动技能在基础技能上扩展释放请求。冷却、范围、目标和动作可以按子对象组织，便于预制技能复用。

## 目录

```text
action.lua  # 技能动作
active.lua  # 主动技能
apis.lua    # 技能 callback API
init.lua    # 技能基础对象与门面
passive.lua # 被动技能
stat.lua    # 技能数值项
target.lua  # 目标选择
trigger.lua # 触发器
```
