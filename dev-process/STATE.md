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

> 最后更新：2026-05-21 16:47
> 写入者：Agent (Claude)

## 当前状态

| 项 | 值 |
| --- | --- |
| 当前版本 | **v0-foundation** |
| 当前活跃任务 | （无 · 等待用户下达 `开始 v0/T02`） |
| 上一完成任务 | ✅ [`v0/T01 dep-check-script`](../dev-plans/v0-foundation/T01-dep-check-script.md)（2026-05-21 验收通过） |
| 下一待办 | [`v0/T02 cmake-skeleton`](../dev-plans/v0-foundation/T02-cmake-skeleton.md) |
| 主 Plan 状态 | building（bootstrap-cross-platform 里程碑进行中：1/5） |
| 阻塞项 | 本机缺 CMake / Ninja / C++ 编译器；T02 启动前需用户安装（详见 v0/T01 acceptance.md 末尾建议） |

## 整体进度

| 版本 | 进度 | 状态 |
| --- | --- | --- |
| v0-foundation | `█░░░░` 1/5 | in_progress |
| v1-mvp | `░░░░░░░░░░░░░░░░░░` 0/18 | pending |
| v2-standard | _未开始_ | not yet |
| v3-full | _未开始_ | not yet |
| v4-release | _未开始_ | not yet |

主 Plan 里程碑：`░░░░░░░░░░` 0/10（bootstrap-cross-platform 进行中：1/5）

## 任务执行状态机（5 步循环）

```
当前: idle → 等待用户 "开始 v0/T02"
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

- `2026-05-21 16:47` **v0/T01 验收通过 → done**：用户确认 DoD 6 条全过；`dev-plans/v0-foundation/README.md` T01 状态翻 done；plan-snapshot.json `active_subtask` → `v0/T02`，新增 `completed_subtasks: [v0/T01]`；新增 `conventions.md §10 脚本文件编码约定`（强制中文 .ps1 用 UTF-8 with BOM）。等用户下达 `开始 v0/T02`。
- `2026-05-21 15:55` **v0/T01 自检完成 → awaiting-acceptance**：4 个 tools 文件全部就绪；T01 文档追加 `## 实现细节`；本机实测 DoD 6 条 5 ✅ 1 部分；关键意外修复——所有 .ps1 加 UTF-8 BOM。
- `2026-05-21 15:34` **v0/T01 进入 Step 3 building**：conventions §9 落地（plan-snapshot.json 增 `local_status` 字段）；tasks/v0-T01-.../{plan.md, execution-log.md} 创建。
- `2026-05-21 15:06` 远程仓库初始化推送完成：HEAD `1397e7a`。
- `2026-05-21 14:40` dev-plans + dev-process 体系建立，27 个文档骨架版生成完毕。

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
| 2026-05-21 15:34 | v0/T01 dep-check-script | idle → in_progress |
| 2026-05-21 15:55 | v0/T01 dep-check-script | in_progress → awaiting-acceptance |
| 2026-05-21 16:47 | v0/T01 dep-check-script | awaiting-acceptance → ✅ done |
