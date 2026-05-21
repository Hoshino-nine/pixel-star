# Tasks

每个子任务一个目录，命名 `vX-Txx-<kebab-name>/`，含 4 个文件：

| 文件 | 写入时机 | 内容 |
| --- | --- | --- |
| `plan.md` | Step 3 开始（building 切换时） | Step 2 制定的细化 Plan 落地副本 |
| `execution-log.md` | Step 3 进行中（中频追加） | 实际改动文件清单、关键决策、踩坑 |
| `self-check.md` | Step 4 自检完成 | DoD 勾选、编译/lint/手测结果 |
| `acceptance.md` | Step 5 用户验收后 | 验收结果与反馈、后续动作 |

> 本目录在每个子任务首次进入 building 时才会出现对应子目录；当前为空。
