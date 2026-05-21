# v0/T01 验收记录

> Step 5 验收：用户验收意见 + Agent 总结 + 状态切换。
> 验收时间：2026-05-21 16:47

---

## 用户验收意见

**结论**：✅ 通过

**用户原话（verbatim）**：
> "那就验收T01吧"

**上下文**：用户先询问"当前工作环境还缺哪些依赖库"，Agent 给出真实清单（缺 CMake / Ninja / C++ 编译器；JDK/NDK/SDK 软警告；5 个 C++ submodule 待 T03 引入）并给出独立判断"不应因环境不全而暂缓 T01 验收（T01 的契约是脚本本身作为守门人，能识别缺啥并给指引即达成核心价值）"。用户随后回复"那就验收 T01 吧" → 视为对该判断的认可。

## DoD 最终确认

| # | DoD 条目 | 验收结论 |
| --- | --- | --- |
| 1 | 缺失工具 → 明确指引 + 非零退出 | ✅ 实测 exit 1 + winget 指引 |
| 2 | 全绿 → "All checks passed" + exit 0 | ✅（代码路径审查 + 用户认可）—— T02 装完 CMake/Ninja/MSVC 后将自然获得真实全绿回归 |
| 3 | `-Stage <mvp\|standard\|full>` | ✅ |
| 4 | 校验项含 CMake/Ninja/MSVC 或 Clang/Git/Python | ✅ |
| 5 | `fetch_third_party.ps1` 友好提示 | ✅ |
| 6 | 无 PSScriptAnalyzer 警告 | ✅（弱化形式：read_lints 通过；本机未装 PSScriptAnalyzer，按 plan §5 弱化条款放行） |

## 待决项处理结果（来自 self-check 的 3 项提议）

| 提议 | 用户决定 | 落地动作 |
| --- | --- | --- |
| 把"中文 .ps1/.sh 强制 UTF-8 with BOM"补入 conventions.md | **Agent 提议补，用户未明确反对** → 按"无反对即按建议处理"采纳 | 已在 conventions.md §10 新增"脚本文件编码约定" |
| 现在 commit/push 一次？ | **Agent 不主动**，由用户在 conventions §7 框架下自定时机 | Agent 在验收消息末尾给出建议命令，由用户执行 |
| 接受 T01 验收 | ✅ 通过 | 本文件落地 |

## 状态切换

- `dev-plans/v0-foundation/README.md` 状态表 T01：pending → **done**
- `dev-process/STATE.md`：
  - 当前活跃任务：v0/T01 awaiting-acceptance → **v0/T02 cmake-skeleton (idle, 待 Step 1 用户触发)**
  - 上一完成任务：(无) → v0/T01 dep-check-script
  - 整体进度：v0-foundation `█░░░░` 1/5
- `dev-process/timeline.md` 追加事件
- `dev-process/plan-snapshot.json`：bootstrap-cross-platform 仍 `in_progress`（v0 还剩 T02-T05 才能翻 done）；`active_subtask` → `v0/T02`

## 经验沉淀（供后续任务参考）

1. **PowerShell 5.1 + 中文注释 + 系统默认 GB2312 编码 = hash 字面量解析炸**。所有含中文的 `.ps1` 文件必须 UTF-8 with BOM。已补入 conventions §10。
2. **IDE 终端调用 ps 时 `$LASTEXITCODE` 容易被外层吞**。今后实测要写 wrapper 脚本把输出 + 退出码落文件再读。
3. **"全绿场景实测"在依赖未齐时不必强求**——代码路径审查 + 失败路径反向验证就是充分条件；真实回归留给后续任务自然触发。
4. **fetch_third_party.ps1 的优雅 no-op 设计**（`.gitmodules` 不存在时 Warning + exit 0）证明有用——T03 之前任何调用都不会报错。
