# 🤖 Agent 接手指南（必读 · 顶部固定）

任何 Agent 进入本项目前，按顺序执行：

1. **读本文件** —— 了解当前活跃任务、版本、整体进度
2. **读 [`../dev-plans/<当前任务对应路径>.md`](../dev-plans/)** —— 了解该任务的契约（要做什么、DoD）
3. **读 [`tasks/<当前任务目录>/`](tasks/) 下全部文件** —— 了解执行进度（plan / execution-log / self-check / acceptance）
4. **读 [`plan-snapshot.md`](plan-snapshot.md)** —— 对齐主 Plan 全貌
5. 才开始工作

> 永远不要直接修改 `dev-plans/`（静态契约）的"目标/DoD"，除非用户在 Step 5 验收时明确要求重写。修订只追加到任务文档底部的 `## 实施回顾` 小节。

---

# PixelStar 开发状态

> 最后更新：2026-05-21 15:06
> 写入者：Agent (Claude)

## 当前状态

| 项 | 值 |
| --- | --- |
| 当前版本 | **v0-foundation** |
| 当前活跃任务 | （无 · 等待用户下达 `开始 v0/T01`） |
| 上一完成任务 | （无 · 项目刚启动） |
| 下一待办 | [`v0/T01 dep-check-script`](../dev-plans/v0-foundation/T01-dep-check-script.md) |
| 主 Plan 状态 | building（已切到 building，但尚未真正进入第一个里程碑的代码工作） |
| 阻塞项 | 无 |

## 整体进度

| 版本 | 进度 | 状态 |
| --- | --- | --- |
| v0-foundation | `░░░░░` 0/5 | pending |
| v1-mvp | `░░░░░░░░░░░░░░░░░░` 0/18 | pending |
| v2-standard | _未开始_ | not yet |
| v3-full | _未开始_ | not yet |
| v4-release | _未开始_ | not yet |

主 Plan 里程碑：`░░░░░░░░░░` 0/10

## 任务执行状态机（5 步循环）

```
当前: idle → 等待用户 "开始 v0/T01"
   ↓
in_progress      （执行中，写 execution-log.md）
   ↓
awaiting-acceptance （自检完成，等用户验收）
   ↓
done / rework
```

## 阻塞 / 待人工干预事项

（暂无）

## 最近事件（最新在前，最多保留 10 条；完整历史见 [`timeline.md`](timeline.md)）

- `2026-05-21 15:06` 远程仓库初始化推送完成：HEAD `1397e7a`，与 `origin/main` 同步，仓库包含 LICENSE + dev-plans + dev-process。
- `2026-05-21 14:40` dev-plans + dev-process 体系建立，27 个文档骨架版生成完毕，等待 `开始 v0/T01`

---

## 给 Agent 的写入约定

每次状态变更，本文件以下字段必须同步更新：

- "当前活跃任务" 与 "下一待办"
- "整体进度" 进度条与计数
- "最近事件" 追加一条（同时也写入 `timeline.md`）
- "最后更新" 时间戳

切换活跃任务时（Step 5 验收通过 → 切到下一个 Step 1）：
- 旧任务从 `awaiting-acceptance` → `done`（写入 `tasks/<id>/acceptance.md`）
- 同步更新 `dev-plans/<vX>/README.md` 的状态表
- 完成整个版本所有任务后，主 Plan 对应里程碑 Todo 标 done，活跃版本切到下一个

---

## 历史活跃任务列表（追加式）

| 时间 | 任务 ID | 状态切换 |
| --- | --- | --- |
| _尚无_ | _等待第一个任务启动_ | _等待中_ |
