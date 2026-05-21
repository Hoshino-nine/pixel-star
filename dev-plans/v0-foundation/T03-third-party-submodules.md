# [v0 / T03] third_party submodules

| 项 | 值 |
| --- | --- |
| 所属版本 | v0-foundation |
| 预计工时 | 2-3 h |
| 前置依赖 | T02 |
| 涉及目录 | `third_party/` / `cmake/deps.cmake` |

## 目标
通过 git submodule 引入 MVP 阶段所需的 5 个第三方库，并在 `cmake/deps.cmake` 中暴露 import target。

## 主要产出
- `.gitmodules`（5 个 submodule 入口）
- `third_party/imgui/`（docking 分支，pin tag v1.90.x）
- `third_party/SDL/`（≥ 2.30 release tag）
- `third_party/stb/`（master）
- `third_party/json/`（v3.11.3 tag）
- `third_party/fmt/`（10.x tag）
- `cmake/deps.cmake` 实现：暴露 `pixelstar::imgui` / `pixelstar::sdl2` / `pixelstar::stb` / `pixelstar::json` / `pixelstar::fmt` 5 个 INTERFACE 或 静态 target

## 验收标准 (DoD 大纲)
- [ ] `git submodule update --init --recursive` 在干净 clone 后能成功
- [ ] `cmake -S . -B build` 不缺任何依赖
- [ ] `cmake/deps.cmake` 中每个 target 在 `app.cpp` 加入 `#include` 测试时可用
- [ ] `tools/check_deps.ps1 -Stage mvp` 校验 submodule 全在
- [ ] submodule 全部 pin 到具体 tag/commit，不用 master HEAD

## 备注
- ImGui 必须 docking 分支（不是 master）
- SDL2 体量较大（含完整源码），首次 clone 慢，文档化提示用户
- nlohmann/json 用 single-header 模式可省时间
- 决策点：fmt 静态库 vs header-only？建议 header-only 减少链接复杂度

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
