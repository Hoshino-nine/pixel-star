# tools/

PixelStar 跨平台开发辅助脚本。**每个子任务开工前应先跑一次 `check_deps`。**

## 脚本一览

| 脚本 | 用途 | 何时运行 |
| --- | --- | --- |
| `check_deps.ps1` | 依赖前置检查（Windows / PowerShell） | 每个子任务开工前；CI 流水线开头 |
| `check_deps.sh` | 同上（Linux / macOS / Bash） | 同上 |
| `fetch_third_party.ps1` | 拉取/更新所有 git submodule | T03 之后；新机器首次 clone 仓库后 |

## 用法

### Windows

```powershell
# v0/v1 阶段（MVP）：检查 Git / CMake / Ninja / MSVC 或 Clang / Python
./tools/check_deps.ps1 -Stage mvp

# v3+ 阶段（完整版）：额外强制检查 JDK 17 / ANDROID_NDK_HOME / fonttools
./tools/check_deps.ps1 -Stage full

# CI / 无 ANSI 终端
./tools/check_deps.ps1 -Stage mvp -NoColor
```

### Linux / macOS

```bash
./tools/check_deps.sh --stage mvp
./tools/check_deps.sh --stage full --no-color
```

> Bash 版与 PowerShell 版语义对齐；MSVC 在非 Windows 平台跳过。

### Stage 语义

| Stage | 必检项 | 软警告项 |
| --- | --- | --- |
| `mvp` (默认) | Git ≥2.40 · CMake ≥3.22 · Ninja ≥1.11 · MSVC 或 Clang · Python ≥3.10 | JDK · ANDROID_NDK_HOME · ANDROID_HOME |
| `standard` | 同 mvp | 同 mvp |
| `full` | mvp 全部 + JDK 17 + ANDROID_NDK_HOME + ANDROID_HOME + fonttools | — |

### 退出码

| 码 | 含义 |
| --- | --- |
| 0 | 所有"必检项"通过（warn 不阻断） |
| 1 | 任一必检项缺失或版本不达标 |
| 2 | 脚本参数错误 |

## 设计约定（重要）

- **检查项以"结构化数组"声明**（`Name` / `Command` / `MinVersion` / `Stages` / `InstallHint`），不要硬编码到流程语句里——便于 T03 之后扩展第三方库子目录校验。
- **不做网络请求、不 Import-Module**：性能预算 < 2 秒。
- **失败时必须给出可操作的安装指引**（winget / brew / apt 命令优先），不能只说"not found"。
- 脚本本身需通过 `Invoke-ScriptAnalyzer` 无警告（如本机已装）。

## 后续扩展点

- **T03 完成后**：在 `check_deps.ps1`/.sh 中启用对 `third_party/{imgui,SDL,stb,json,fmt}` 五个子目录非空的强校验（脚本里已留 `TODO(T03)` 标记）。
- **T16 完成后**：Android 工具链相关检查从 warn 升级为 mvp 必检（如 PixelStar 移动端持续 CI 的话）。
