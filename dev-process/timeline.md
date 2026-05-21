# PixelStar 全局事件时间线

> 追加式记录，最新在底部。每条 1-2 行，含时间戳。
> 本文件与 `STATE.md "最近事件"` 互补：STATE 只保留最近 10 条作快速查看，本文件保留全部。

---

- `2026-05-21 14:40` **体系建立**：dev-plans/ 顶层 README + conventions + v0(6 文件) + v1(19 文件) 共 27 个静态契约骨架文档生成完毕；dev-process/ 含 STATE/plan-snapshot.{md,json}/timeline/handoffs/tasks 共 6 项动态归档体系初始化完毕。等待用户下达 `开始 v0/T01`。
- `2026-05-21 15:06` **远程仓库初始化**：本地 `git init -b main` + `.gitignore`（排除 `.codebuddy/` / `.agents/` / `skills-lock.json` / 构建产物）+ commit `f31d6ed` 共 34 文件 1393 inserts；绑定 `origin = https://github.com/Hoshino-nine/pixel-star.git`；远程已存在 `64ad669 Initial commit (LICENSE)`，用 `git pull --rebase --allow-unrelated-histories` 线性合并后推送成功。当前 HEAD `1397e7a` 与 `origin/main` 同步。
- `2026-05-21 15:30` **conventions §9 与 plan-snapshot.json `local_status` 字段落地**：明确 Plan Artifact 是"工作台、用完即弃"，进度真相由 `dev-process/` 落地文档维持；plan-snapshot.json 现含 10 个里程碑的 `local_status` + `active_subtask` 字段，bootstrap-cross-platform = in_progress, active_subtask = v0/T01。
- `2026-05-21 15:34` **v0/T01 进入 Step 3 building**：`tasks/v0-T01-dep-check-script/{plan.md, execution-log.md}` 创建；STATE.md 当前活跃任务切到 v0/T01，状态 in_progress；IDE todolist 替换为本任务 7 步执行清单。下一步开始写 `tools/check_deps.ps1`。
- `2026-05-21 15:55` **v0/T01 自检完成 → awaiting-acceptance**：4 个 tools 文件就绪（check_deps.ps1/.sh + fetch_third_party.ps1 + tools/README.md）；T01 契约文档追加 `## 实现细节`；本机实测：缺失场景 ✅（exit 1 + 安装指引）、Stage 参数 ✅、`fetch_third_party.ps1` 优雅 no-op ✅、`read_lints` 无警告；全绿场景因本机缺 CMake/Ninja/MSVC 用代码路径审查通过。**关键意外**：PowerShell 5.1 在系统默认 GB2312 编码下解析无 BOM UTF-8 + 中文字符的脚本会破坏 hash 字面量；修复方案——给所有 `tools/*.ps1` 加 UTF-8 BOM（建议补入 conventions）。详见 [`self-check.md`](tasks/v0-T01-dep-check-script/self-check.md)。
- `2026-05-21 16:47` **v0/T01 验收通过 → done**：用户确认 DoD 6 条全过；`dev-plans/v0-foundation/README.md` T01 状态翻 done；plan-snapshot.json `active_subtask` 切到 `v0/T02`、新增 `completed_subtasks: [v0/T01]`；conventions.md 新增 §10「脚本文件编码约定」（强制中文 .ps1 用 UTF-8 with BOM；中文 .sh/.md 无 BOM）；v0-foundation 进度 1/5。**本机仍缺 CMake / Ninja / C++ 编译器**，T02 启动前需用户先 winget 安装。
