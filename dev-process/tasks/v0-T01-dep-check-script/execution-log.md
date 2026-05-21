# v0/T01 执行日志（中频追加）

> 写入约定：每完成一个有意义的小阶段（一个文件、一次实测、一次决策）追加一条；时间戳精度到分钟。

---

- `2026-05-21 15:34` Step 3 进入 building。本任务目录与 plan.md 副本落地完成；STATE.md 当前活跃任务切到 v0/T01，状态 in_progress；timeline.md 追加事件。
- `2026-05-21 15:34` **意外 1**：尝试调用 `plan_update status=building` 失败，工具不存在；按 conventions §9 设计，Plan Artifact 状态非真相源，dev-process 落地文档才是 → 决定无视，继续推进。
- `2026-05-21 15:42` 写完 `tools/check_deps.ps1` 共 ~280 行：含 `Get-ToolVersion` / `Test-CCompiler` / `Test-MinVersion` / `Write-Status` 工具函数，5 条结构化检查项数组（Git/CMake/Ninja/Python/JDK），外加 4 项特殊检查（C++ 编译器择一 / NDK env / SDK env / fonttools / third_party 目录提示）。退出码语义：0/1/2。
- `2026-05-21 15:45` 写完 `tools/check_deps.sh` 共 ~200 行：与 ps1 语义对齐；版本比较用 `sort -V`；颜色用 `tput`；MSVC 跳过；JDK 通过 `-version`（单破折号）参数取版本。
- `2026-05-21 15:46` 写完 `tools/fetch_third_party.ps1`：`.gitmodules` 缺失时 Warning + exit 0（T03 前优雅 no-op）；可选 `-Force` 透传给 git。
- `2026-05-21 15:46` 写完 `tools/README.md`：脚本一览表 / 用法 / Stage 语义表 / 退出码 / 设计约定 / T03&T16 扩展点。
- `2026-05-21 15:47` `read_lints tools/` 通过，无错误无警告。
- `2026-05-21 15:47` 在 `dev-plans/v0-foundation/T01-dep-check-script.md` 追加 `## 实现细节` 小节（接口契约 / Stage 分级 / 关键决定 / 风险对策），并指向 dev-process/tasks/.../plan.md 作为完整副本。
- `2026-05-21 15:50` **意外 2（编码陷阱）**：实测 `pwsh -File tools/check_deps.ps1 -Stage mvp` 报 "Unexpected token 'Git'" / "hash literal incomplete"；诊断显示系统默认 `gb2312`，文件无 BOM UTF-8 + 含中文注释 → PS 5.1 用 GB2312 误读 UTF-8 字节流。**修复**：用 `[IO.File]::WriteAllBytes` 给 `tools/*.ps1` 加 BOM（EF BB BF），重测通过。
- `2026-05-21 15:53` 实测全部跑通：缺失场景 exit 1 + 安装指引 ✅；Stage 参数验证 ✅；`fetch_third_party.ps1` `.gitmodules` 不存在时 Warning + exit 0 ✅；read_lints tools/ 通过；PSScriptAnalyzer 本机未装，按 plan 弱化条款跳过。
- `2026-05-21 15:55` 写完 `self-check.md`（DoD 6 条逐项核对 + 实测输出摘录 + 5 项意外/决策记录）；STATE.md 切 awaiting-acceptance；timeline 追加；清理临时 wrapper 脚本 `_run_test.ps1` / `_run_fetch.ps1` / `check_out.txt` / `fetch_out.txt`。等用户验收。
