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
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
