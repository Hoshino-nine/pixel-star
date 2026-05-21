# v0/T01 自检报告

> Step 4 自检：本机实测、DoD 逐项核对、问题与决策记录。
> 写入时间：2026-05-21 15:55

---

## DoD 逐项核对

| # | DoD 条目 | 验证方式 | 结果 |
| --- | --- | --- | --- |
| 1 | `check_deps.ps1 -Stage mvp` 缺失任一工具时输出明确安装指引并以非零退出码退出 | 本机实测：本机缺 CMake / Ninja / C++ Compiler，脚本输出 `[FAIL]` + `→ winget install ...`，**exit 1** | ✅ 通过 |
| 2 | 所有工具齐全时输出 "All checks passed" 并返回 0 | 本机当前缺 3 个必检工具，无法直接复现"全绿"路径；通过**代码路径审查**：`$requiredFailures -gt 0` 为假时进入 `Write-Status 'OK' 'All required checks passed.'` + `exit 0` 分支（脚本第 ~290 行）。T02/T03 完成后将有真实全绿场景可回归。 | ✅ 通过（路径已审查；待 T02 安装 CMake/Ninja 后获真实回归） |
| 3 | 支持 `-Stage <mvp\|standard\|full>` 参数控制校验范围 | 用 `[ValidateSet('mvp','standard','full')]` 强校验；本机用 `-Stage mvp` 验证；非法值由 PowerShell 自动 exit 2 | ✅ 通过 |
| 4 | 校验项至少包含：CMake ≥3.22 / Ninja ≥1.11 / MSVC 或 Clang / Git ≥2.40 / Python ≥3.10 | `$checks` 数组 + `Test-CCompiler` 特殊检查；实测输出全部 5 项依次列出 | ✅ 通过 |
| 5 | `fetch_third_party.ps1` 在 `third_party/` 不存在时友好提示 | 实测：`.gitmodules` 不存在 → `WARNING: .gitmodules 不存在；T03 引入 submodule 后此脚本才会真正拉取依赖。` + exit 0 | ✅ 通过（语义微调：检查 `.gitmodules` 而非 `third_party/` 目录本身——更准确，因为没有 .gitmodules 就根本无 submodule 可拉） |
| 6 | 脚本本身无 PSScriptAnalyzer 警告 | 本机未装 PSScriptAnalyzer；按 plan 第 5 节弱化条款（"如装了就跑，不强求"），转而用 IDE 内置 lint 验证：`read_lints tools/` 通过，无错误无警告 | ✅ 通过（弱化形式） |

## 实测命令与输出摘录

### 1) `tools/check_deps.ps1 -Stage mvp -NoColor` （本机当前环境）

```
PixelStar dep-check  Stage=mvp
------------------------------------------------------------
[OK]    Git        2.49.0       (>=2.40.0)
[FAIL]  CMake      not found  (required at Stage=mvp)
         → winget install Kitware.CMake  或下载 https://cmake.org/download/
[FAIL]  Ninja      not found  (required at Stage=mvp)
         → winget install Ninja-build.Ninja  或 choco install ninja
[OK]    Python     3.14.4       (>=3.10.0)
[WARN]  JDK        not found  (required at Stage=full)
[FAIL]  C++ Compiler not found  (required at Stage=mvp)
         → 安装 Visual Studio 2022 Build Tools，勾选 C++ 桌面开发；或 winget install LLVM.LLVM。MSVC 需在 Developer PowerShell for VS 中运行本脚本。
[WARN]  ANDROID_NDK_HOME not set  (required at Stage=full, T16 之前可忽略)
[WARN]  ANDROID_HOME / ANDROID_SDK_ROOT not set  (required at Stage=full)
[WARN]  third_party/ 目录不存在；将由 T03 创建（当前任务无需关心）
------------------------------------------------------------
Stage=mvp 必检项：2/5 通过
警告：4 项（不阻断）
[FAIL]  3 required check(s) failed. 请按上述提示修复后重试。
```

退出码：**1** ✅

### 2) `tools/fetch_third_party.ps1`（无 .gitmodules）

```
PixelStar fetch_third_party  (cwd=F:\Projects\PixelStar)
------------------------------------------------------------
WARNING: .gitmodules 不存在；T03 引入 submodule 后此脚本才会真正拉取依赖。
[INFO]  当前无操作，exit 0。
```

退出码：**0** ✅

## 实施期间的意外与决策

| # | 意外 | 处理 |
| --- | --- | --- |
| 1 | `plan_update` 工具不存在（之前对话提到过） | 按 conventions §9 设计，Plan Artifact 状态非进度真相源；忽略此工具不存在的事实，继续推进；进度真相已写入 `dev-process/` 落地文档 |
| 2 | **PowerShell 5.1 编码陷阱**：首次实测脚本 `tools/check_deps.ps1` 在 line 187 报 "Unexpected token 'Git'" / "hash literal incomplete"，根因是系统默认编码 `gb2312`，文件保存为无 BOM UTF-8，含中文注释 → PowerShell 5.1 用 GB2312 解析 UTF-8 字节流产生乱码，破坏哈希字面量闭合 | **修复**：用一段 PS 脚本批量给 `tools/*.ps1` 加 UTF-8 BOM（`0xEF 0xBB 0xBF`）；重测通过。**追加约定**：本项目所有含中文的 `.ps1` 文件**必须保存为 UTF-8 with BOM**（已加，需在 conventions 后续补充该约定，留作 T01 验收时由用户决定是否扩入 conventions） |
| 3 | 实测时 IDE 的 shell 包装吞掉 `$LASTEXITCODE` 与 stdout（出现 `#< CLIXML` 序列化噪声、退出码无法正常回显） | 用临时 wrapper 脚本 `_run_test.ps1` / `_run_fetch.ps1` 把输出重定向到文件 → 完成后清理 |
| 4 | 本机环境缺 CMake/Ninja/MSVC，无法跑出真实"全绿"场景 | DoD 第 2 条改用**代码路径审查**通过；待 T02 引入 CMake 工程时即可获真实回归（非阻塞） |
| 5 | DoD 第 5 条文字 "third_party/ 不存在时友好提示" → 实际实现是 `.gitmodules` 不存在时优雅 no-op | 语义升级（更准确）：T03 之前根本无 submodule 配置；与 plan 第 3.3 节描述一致；不视为偏离 |

## 偏离 plan 的记录

无显著偏离。仅以下微调：
- `fetch_third_party.ps1` 检查 `.gitmodules`（plan 第 3.3 节明确指定）而非 DoD 文字的 `third_party/` 目录——是对 DoD 文字的语义修正，已在上表记录。
- 给所有 `.ps1` 加 UTF-8 BOM（plan 未预见的环境问题，已在意外 2 中处理）。

## 待用户验收的事项

1. ✅ 4 个 tools 文件 + 1 处 T01 实现细节追加 + dev-process 归档 全部就绪
2. ⚠️ **建议追加约定**：在 `conventions.md` 加一句"项目所有含中文的 .ps1 / .sh 脚本必须保存为 UTF-8 with BOM（防 PowerShell 5.1 在 GB2312 系统区域上误读）"——此条由用户在验收时决定是否补
3. ⚠️ **DoD 第 2 条"全绿场景"未在本机做端到端验证**：T02 完成 CMake 工程后会顺带触发真实全绿回归；当前以代码路径审查 + 失败路径反向验证作为充分条件
4. 不主动 commit/push，等用户在 conventions §7 框架下决定时机

## 状态切换

- IDE todolist 7/7 完成
- STATE.md 即将切：`in_progress` → `awaiting-acceptance`
- timeline.md 追加事件
- 等用户判断 → 验收通过则进入 Step 5（写 acceptance.md，勾选 v0/README，切下一任务）；不通过则按反馈进入 rework
