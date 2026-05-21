# v0/T01 细化 Plan：dep-check 脚本

> 本文件是 Step 2 细化 Plan 的永久副本（防 Plan Artifact 被下个子任务覆盖时丢失）。
> 来源：用户在 Step 2 出 Plan 时确认；Step 3 building 起即冻结，后续修订只追加到末尾"## 实施回顾"。

---

## 1. 目标精确化

构建一个**会被频繁调用、快速、明确、可分阶段**的依赖前置检查守门人脚本。本任务**只交付脚本本身**，不引入任何 C++ 依赖、不创建 third_party、不写 CMake——这些是 T02/T03 的事。

## 2. 范围边界（重要 · 防止越界）

**本次做**：
- `tools/check_deps.ps1`（Windows，PowerShell 5.1+ 兼容 7.x）
- `tools/check_deps.sh`（Bash，POSIX 友好；Windows 端不强求可用，作为 Linux/macOS 对等占位）
- `tools/fetch_third_party.ps1`（仅做 `git submodule update --init --recursive` + 友好提示，不预拉任何具体库）
- `tools/README.md`（脚本入口与用法说明，简短）

**本次不做**：
- 真正的 submodule 配置（T03）
- NDK/SDK/JDK 实质校验逻辑（仅占位 + Stage=mvp 不强校验，符合 conventions/SOP）
- CMake 工程文件（T02）

## 3. 实现细节

### 3.1 `tools/check_deps.ps1` 设计

**参数：**
```powershell
[CmdletBinding()]
param(
    [ValidateSet('mvp','standard','full')]
    [string]$Stage = 'mvp',
    [switch]$NoColor   # CI 环境兜底
)
```

**核心数据结构**（脚本内部，每条检查项标准化定义）：
- `Name` / `Command` / `VersionArgs` / `VersionRegex` / `MinVersion` / `Stages` / `InstallHint` / `Optional`

**MVP 阶段必检项**（与主 Plan 依赖清单一致）：

| Name | Min | InstallHint |
| --- | --- | --- |
| Git | 2.40.0 | `winget install Git.Git` |
| CMake | 3.22.0 | `winget install Kitware.CMake` |
| Ninja | 1.11.0 | `winget install Ninja-build.Ninja` 或 `choco install ninja` |
| MSVC 或 Clang | VS2022 / Clang 16 | "安装 Visual Studio 2022 Build Tools，勾选 C++ 桌面开发" |
| Python | 3.10.0 | `winget install Python.Python.3.12` |

**MVP 阶段软警告项**（warn 不 fail）：
- `JDK 17`（T16 才需要）
- `ANDROID_NDK_HOME` 环境变量（T16 才需要）
- `ANDROID_HOME` 或 `ANDROID_SDK_ROOT`（T16 才需要）

**Standard 阶段**：与 MVP 相同。

**Full 阶段追加**：
- JDK 17 升为必检
- ANDROID_NDK_HOME 升为必检
- `fonttools`（`pip show fonttools`）

**第三方库 submodule 校验（按 Stage 分阶段）**：
- 本任务版本：仅检查 `third_party/` 目录是否存在；不存在 → warn 提示运行 `fetch_third_party.ps1`；存在但空 → warn。**不校验具体子目录**（T03 引入 submodule 后再补）。
- 留 TODO 注释明确：T03 完成后 MVP 阶段必须包含 `third_party/imgui` `third_party/SDL` `third_party/stb` `third_party/json` `third_party/fmt` 五个子目录非空。

**MSVC / Clang 检查实现**：
- 优先尝试 `Get-Command cl.exe -ErrorAction SilentlyContinue`
- 找不到则 `Get-Command clang.exe`
- 都找不到 → 提示用 VS Developer PowerShell 打开，或安装 VS 2022 Build Tools；版本严格度 MVP 宽松（任一即可），仅打印检测到的版本。

**版本比较**：
- 提取版本号末尾 `X.Y[.Z]`，用 `[version]` 类型比较；缺第三段补 `.0`。

**输出格式（带颜色，可被 `-NoColor` 关闭）**：
```
PixelStar dep-check  Stage=mvp
[OK]   Git        2.45.1   (>=2.40.0)
[OK]   CMake      3.29.3   (>=3.22.0)
...
[WARN] JDK 17 not found (required at Stage=full)
---
Stage=mvp 必检项：5/5 通过
警告：3 项（不阻断）
All required checks passed.
```

**退出码**：
- 0：所有"必检项"通过（warn 不影响退出码）
- 1：任一必检项缺失或版本不达标
- 2：脚本自身参数错误

**性能要求 <2s**：
- 全部 `Get-Command` + 版本提取，单次约 300-800 ms
- 不做网络请求，不 `Import-Module`

### 3.2 `tools/check_deps.sh` 设计

- `bash tools/check_deps.sh --stage mvp`
- `command -v` 检测命令存在；`<tool> --version | head -n1` 提取版本
- `sort -V` 比较版本
- 颜色用 `tput colors` 检测；不支持时降级
- 退出码语义与 ps1 一致
- MSVC 在 Unix 下跳过（OK with note "Skipped on non-Windows"）

### 3.3 `tools/fetch_third_party.ps1` 设计

- 定位仓库根（`$PSScriptRoot/..`）
- 检查 `.gitmodules`，不存在 → Warning + exit 0（优雅 no-op）
- 存在 → `git submodule update --init --recursive`

### 3.4 `tools/README.md`

简洁的入口表格 + Stage 用法示例。

## 4. 验收对应（DoD 映射）

| DoD 大纲项 | 实现支撑点 |
| --- | --- |
| 缺失项给明确安装指引 + 非零退出码 | `InstallHint` + exit 1 |
| 全绿输出 "All checks passed" 返回 0 | 末尾汇总 + exit 0 |
| 支持 `-Stage <mvp\|standard\|full>` | `[ValidateSet]` 参数 |
| 校验项含 CMake/Ninja/MSVC 或 Clang/Git/Python | MVP 必检表 |
| `fetch_third_party.ps1` third_party 不存在时友好提示 | `.gitmodules` 检查 + exit 0 |
| 无 PSScriptAnalyzer 警告 | 写完跑 `Invoke-ScriptAnalyzer tools/*.ps1` 自检（如装了） |

## 5. 风险与决策

| 风险 | 处理 |
| --- | --- |
| PowerShell 5.1 vs 7.x 行为差异 | 避用 7.x 独有语法；`#requires -Version 5.1` |
| 用户开发环境是 cmd 而非 PowerShell | conventions 已规定脚本运行在 PowerShell |
| 没装 PSScriptAnalyzer | 自检"如装了就跑"，不强求 |
| `cl.exe` 必须 VS Dev Prompt | MVP 宽松：`cl` 或 `clang` 任一即可 |
| Bash 在 Windows 默认不可用 | `.sh` 仅作占位对等；DoD 不强求 Windows 通过 |

## 6. 改动文件清单

**新增（5 个）：**
- `tools/check_deps.ps1`
- `tools/check_deps.sh`
- `tools/fetch_third_party.ps1`
- `tools/README.md`
- `dev-process/tasks/v0-T01-dep-check-script/{plan.md, execution-log.md, self-check.md, acceptance.md}`

**修改（3 个）：**
- `dev-plans/v0-foundation/T01-dep-check-script.md`：追加 `## 实现细节` 小节
- `dev-plans/v0-foundation/README.md`：T01 状态 pending → done（Step 5 验收后）
- `dev-process/STATE.md` + `dev-process/timeline.md`：Step 3 进入 building 时与 Step 5 验收时分别更新

## 7. 执行顺序（building 阶段，对应 IDE todolist 7 步）

1. 落地 `dev-process/tasks/v0-T01-dep-check-script/{plan.md, execution-log.md}` + 更新 STATE/timeline
2. 写 `tools/check_deps.ps1`
3. 写 `tools/check_deps.sh`
4. 写 `tools/fetch_third_party.ps1`
5. 写 `tools/README.md`
6. 在 `T01-dep-check-script.md` 追加 "## 实现细节"
7. 本机实测全绿 + 故意失败 + 可选 PSScriptAnalyzer → 写 `self-check.md` → STATE→awaiting-acceptance + plan_update status=finished

## 8. 不会发生的事（明示）

- 不创建 `third_party/`、不创建 `CMakeLists.txt`、不引入任何 C++ 库
- 不修改全局 `git config`
- 不动 `.gitignore`（已就绪）
- 不主动 commit/push（按 conventions §7，由用户决定时机）

---

## 实施回顾

（待 Step 4/5 追加：实际执行中遇到的偏差、决定、未预料到的问题及处理）
