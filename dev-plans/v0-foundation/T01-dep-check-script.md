# [v0 / T01] dep-check 脚本

| 项 | 值 |
| --- | --- |
| 所属版本 | v0-foundation |
| 预计工时 | 2-3 h |
| 前置依赖 | - |
| 涉及目录 | `tools/` |

## 目标
编写跨平台依赖前置检查脚本，作为后续每个子任务开工前的统一守门人。

## 主要产出
- `tools/check_deps.ps1`（Windows，PowerShell）
- `tools/check_deps.sh`（Unix，Bash，跨平台对等）
- `tools/fetch_third_party.ps1`（拉取/更新 git submodule）

## 验收标准 (DoD 大纲)
- [ ] `check_deps.ps1 -Stage mvp` 在缺失任一工具时输出明确安装指引并以非零退出码退出
- [ ] 所有工具齐全时输出 "All checks passed" 并返回 0
- [ ] 支持 `-Stage <mvp|standard|full>` 参数控制校验范围
- [ ] 校验项至少包含：CMake ≥3.22 / Ninja ≥1.11 / MSVC 或 Clang / Git ≥2.40 / Python ≥3.10
- [ ] `fetch_third_party.ps1` 在 `third_party/` 不存在时友好提示
- [ ] 脚本本身无 PSScriptAnalyzer 警告

## 备注
- 脚本会被频繁调用，要快（<2 秒）
- 后续 T03 会引入 submodule 校验，T04 会让 `--Stage mvp` 实际触发完整 MVP 库检查
- 决策点：检查 NDK/SDK 时要不要强制 `ANDROID_NDK_HOME` 环境变量？建议 Stage=mvp 时仅 warn，Stage=full 时 error

---

## 实现细节（Step 2 细化 Plan 后冻结）

> 完整版细化 Plan 见 [`dev-process/tasks/v0-T01-dep-check-script/plan.md`](../../dev-process/tasks/v0-T01-dep-check-script/plan.md)。本节只摘录契约层面的关键约定。

### 产出文件（最终 4 个）

- `tools/check_deps.ps1`（Windows / PowerShell 5.1+，兼容 7.x）
- `tools/check_deps.sh`（Linux / macOS / Bash 4+）
- `tools/fetch_third_party.ps1`（git submodule 包装，`.gitmodules` 不存在时 no-op）
- `tools/README.md`

### 接口契约

**check_deps.ps1 / .sh 公共契约**：
- 参数：`-Stage <mvp|standard|full>`（默认 `mvp`）；`-NoColor` / `--no-color`
- 退出码：0 全绿、1 必检失败、2 参数错误
- 性能：< 2 秒
- 副作用：仅读取 PATH / 环境变量 / 文件系统；**不联网**、**不写文件**

**fetch_third_party.ps1**：
- `.gitmodules` 不存在 → Warning + `exit 0`（优雅 no-op，T03 之前调用不报错）
- 存在 → `git submodule update --init --recursive`，`exit $LASTEXITCODE`
- 可选 `-Force` 标志透传 `--force`

### Stage 必检项与软警告分级

| Stage | 必检项 | 软警告项（warn 不阻断） |
| --- | --- | --- |
| `mvp` / `standard` | Git ≥2.40 · CMake ≥3.22 · Ninja ≥1.11 · MSVC 或 Clang · Python ≥3.10 | JDK 17 · ANDROID_NDK_HOME · ANDROID_HOME |
| `full` | 上述 + JDK 17 + ANDROID_NDK_HOME + ANDROID_HOME + `pip show fonttools` | — |

### 关键设计决定

- 检查项使用**结构化数组声明**（`Name`/`Command`/`VersionArgs`/`VersionRegex`/`MinVersion`/`Stages`/`InstallHint`），便于 T03/T16 扩展。
- **C++ 编译器走特殊检查**：`cl.exe` 或 `clang.exe` 任一即通过（择一）；都缺则 fail 并提示用 VS Developer PowerShell 或 winget LLVM。
- **Bash 版不检查 MSVC**：在非 Windows 平台输出 `[INFO] MSVC skipped on non-Windows`，不计入必检统计。
- **third_party/ 校验留 TODO(T03)**：本任务版本仅检查目录存在性；具体子目录（imgui/SDL/stb/json/fmt）非空校验由 T03 引入 .gitmodules 时再启用，注释里已显式标注。
- **版本比较**：PS 用 `[version]` 类型比较（缺三段补 `.0`）；Bash 用 `sort -V`。
- **NDK/SDK 决策**：按"备注"中决策点处理——mvp 仅 warn，full 必检。

### 风险与对策

| 风险 | 对策 |
| --- | --- |
| PowerShell 5.1 vs 7.x 行为差异 | 避用 7.x 独有语法（`??`/`?:`），加 `#requires -Version 5.1` |
| `cl.exe` 必须 VS Dev Prompt 才可见 | 宽松策略：`cl` 缺失但 `clang` 存在仍算通过 |
| 用户没装 PSScriptAnalyzer | 自检"如装了就跑"，DoD 弱化为"无明显语法错误 + 无 lint 报红" |
| `java -version` 走 stderr | `Get-ToolVersion` 用 `2>&1 | Out-String` 合并流 |
| Bash 在 Windows 默认不可用 | `.sh` 仅作 Linux/macOS 对等占位，不强求 Windows 通过 |
