# PixelStar 开发计划总索引

> 本目录存放**静态契约**：每个子任务"要做什么、怎么验收"。
> 动态进度记录在 `dev-process/STATE.md`，请先看那里。

## 三级文档体系

```
主 Plan（CodeBuddy plans）  → 10 个里程碑 Todo
        ↓
dev-plans/vX/README.md      → 版本目标 + 子任务状态表
        ↓
dev-plans/vX/Txx-*.md       → 单个子任务契约（骨架版）
```

## 版本路线图

| 版本 | 目录 | 子任务数 | 主 Plan 里程碑 | 状态 |
| --- | --- | --- | --- | --- |
| v0-foundation | [v0-foundation/](v0-foundation/) | 5 | bootstrap-cross-platform | pending |
| v1-mvp | [v1-mvp/](v1-mvp/) | 18 | canvas-render-pipeline + mvp-tools-and-ui + png-export-and-android-shell | pending |
| v2-standard | _进入时生成_ | ~11 | layers-shapes-mirror-picker + sprite-sheet-export | not yet |
| v3-full | _进入时生成_ | ~17 | frame-animation-system + pxs-and-aseprite-io + android-polish | not yet |
| v4-release | _进入时生成_ | ~10 | performance-and-release | not yet |

## 当前进度指针

详见 [`../dev-process/STATE.md`](../dev-process/STATE.md)

## 通用约定

- DoD 模板、check_deps SOP、execution-log 频率、Git 提交规范：见 [`conventions.md`](conventions.md)
- 单任务文档骨架结构：见 `conventions.md` 的"任务文档模板"小节
