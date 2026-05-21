# v0-foundation · 基础设施版

> **对应主 Plan 里程碑**：`bootstrap-cross-platform`
> **版本目标**：搭好跨平台开发地基，让 Windows 桌面能跑起一个空 ImGui 窗口；统一依赖前置检查与日志基础设施。
> **退出条件**：
> - `tools/check_deps.ps1 -Stage mvp` 全绿
> - `cmake --build build` 通过
> - 运行 desktop 版可看到一个标题为 "PixelStar" 的空 ImGui 窗口
> - 5 个子任务全部验收通过

## 任务状态表

| ID | 任务 | 预计工时 | 前置 | 状态 |
| --- | --- | --- | --- | --- |
| T01 | [dep-check 脚本](T01-dep-check-script.md) | 2-3 h | - | pending |
| T02 | [CMake 跨平台骨架](T02-cmake-skeleton.md) | 3-4 h | T01 | pending |
| T03 | [third_party submodules](T03-third-party-submodules.md) | 2-3 h | T02 | pending |
| T04 | [SDL2 + ImGui 引导](T04-sdl2-imgui-bootstrap.md) | 4-6 h | T03 | pending |
| T05 | [日志基础设施](T05-logging-foundation.md) | 2-3 h | T04 | pending |

## 入口任务

从 `T01` 开始按顺序推进。

## 完成后

更新 `dev-process/STATE.md` 把主 Plan 里 `bootstrap-cross-platform` 标记为 done，并切换活跃版本为 `v1-mvp`。
