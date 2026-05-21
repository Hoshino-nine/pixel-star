# [v0 / T05] 日志基础设施

| 项 | 值 |
| --- | --- |
| 所属版本 | v0-foundation |
| 预计工时 | 2-3 h |
| 前置依赖 | T04 |
| 涉及目录 | `src/util/` |

## 目标
建立基于 fmt 的分级日志宏，Release 编译期剔除 Debug，Android 桥接到 logcat。

## 主要产出
- `src/util/log.h`（核心宏：`LOG_E` / `LOG_W` / `LOG_I` / `LOG_D`）
- `src/util/log.cpp`（实现：桌面打印 stderr + 时间戳；Android 用 `__android_log_print`）
- 在 `app.cpp` 启动时 `LOG_I("PixelStar starting...")` 验证

## 验收标准 (DoD 大纲)
- [ ] Debug 编译下 4 个级别全部输出
- [ ] Release 编译下 `LOG_D` 在编译期被剔除（`if constexpr (false)`），无字符串残留
- [ ] 输出格式：`[YYYY-MM-DD HH:MM:SS.mmm][LEVEL][file:line] message`
- [ ] 不允许日志阻塞主循环（同步即可，但单条 ≤ 0.1 ms）
- [ ] fmt 编译期类型检查生效（错误格式串触发编译错误）
- [ ] Android 桥接代码可 compile（实际 Android 跑通推迟到 v1/T16）

## 备注
- 日志接口要为后续 telemetry（v1/T14）预留——telemetry 不依赖 LOG，但同样使用 fmt
- 决策点：是否引入异步日志？MVP 阶段不需要，标记为 v4 候选优化项
- 注意：触摸事件、渲染循环禁止打日志（即便 Debug 也会拖慢）

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
