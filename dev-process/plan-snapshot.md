# 主 Plan 落地副本（Plan Snapshot）

> 最后同步：2026-05-21 14:40
> 来源：CodeBuddy plan id `d83b665d47fa4f97ad19d7f2eb1e56e8`
> 此文件每次主 Plan 变更后同步刷新；机器可读版见 [`plan-snapshot.json`](plan-snapshot.json)

## 元信息

| 项 | 值 |
| --- | --- |
| 名称 | PixelStar - Android 像素画 App 开发计划 |
| 状态 | building |

## 概述

基于 Dear ImGui + SDL2 + C++17 + OpenGL ES 3.0 技术栈，开发一款轻量、高性能、低发热的 Android 像素画 App，支持 Windows 桌面联合调试。采用迭代式交付：MVP（单帧绘画 + PNG 导出，2 周）→ 标准版（完整工具集 + 图层 + Sprite Sheet）→ 完整版（动画 + GIF/APNG + 项目文件 + Aseprite 兼容）。

## 主 Plan 10 个里程碑 Todo

| # | ID | 状态 | 内容摘要 | 对应 dev-plans |
| --- | --- | --- | --- | --- |
| 1 | `bootstrap-cross-platform` | pending | 建立 dev-plans + dev-process 体系；v0/T01-T05：依赖检查 → submodule → CMake → SDL2+ImGui → 日志 | v0-foundation/ |
| 2 | `canvas-render-pipeline` | pending | Canvas/Layer 数据 → GLRenderer → Dirty Rect 管线；桌面渲染纯色画布 + 棋盘 | v1-mvp/T01-T03 |
| 3 | `mvp-tools-and-ui` | pending | InputEvent → 4 工具 → History → theme.json → widgets → 工具栏 → 抽屉 → 调色板 → 手势 → telemetry | v1-mvp/T04-T14 |
| 4 | `png-export-and-android-shell` | pending | PNG 导出 → Android Gradle 壳 → JNI MediaStore → MVP 双端验收 | v1-mvp/T15-T18 |
| 5 | `layers-shapes-mirror-picker` | pending | 图层 / 几何工具 / 选区 / 镜像 / HSV 拾取 / 参考图（v2 进入时生成子任务） | v2-standard/ |
| 6 | `sprite-sheet-export` | pending | Sprite Sheet 导出 + JSON 元数据；标记 v2 完成 | v2-standard/ |
| 7 | `frame-animation-system` | pending | 帧时间线 / 洋葱皮 / GIF/APNG/WebP 导出（v3 进入时生成子任务） | v3-full/ |
| 8 | `pxs-and-aseprite-io` | pending | .pxs 项目文件 / Aseprite JSON 兼容 | v3-full/ |
| 9 | `android-polish` | pending | 压感 / 分享 Intent / 主题切换 / 中英双语 / Thermal API / 调试面板 / Stitch 接入 | v3-full/ |
| 10 | `performance-and-release` | pending | 性能调优 / 文档 / Release APK | v4-release/ |

## 关键技术决策（与本仓库代码强相关）

- **UI 框架**：Dear ImGui (docking 分支) + SDL2 ≥ 2.30
- **语言/构建**：C++17 + CMake 3.22+ + Gradle 8.x
- **渲染**：OpenGL 3.3 Core（桌面）/ OpenGL ES 3.0（Android）
- **Android**：minSdk 29 (Android 10+) / targetSdk 34 / NDK r26d / arm64-v8a + armeabi-v7a
- **第三方库**（git submodule + CMake FetchContent）：
  - MVP：imgui (docking) / SDL2 / stb / nlohmann/json / fmt
  - 完整版增量：giflib / libwebp / miniz
- **画布**：默认 512×512，最多 1024×1024 / 16 图层
- **性能策略**：脏矩形 + 单纹理上传 + 自适应 30/60Hz + 命令池化 + RLE 压缩
- **遥测**：本地 JSONL 滚动日志，按日切分，保留 7 天，无网络权限
- **UI 主题**：从 `assets/themes/*.json` 加载，运行时热切换，便于 Google Stitch 接入

## 依赖清单（系统级）

| 类别 | 工具 | 版本 |
| --- | --- | --- |
| 编译器 | MSVC (VS 2022) 或 Clang | ≥ Clang 16 |
| 构建 | CMake / Ninja | ≥ 3.22 / ≥ 1.11 |
| Android | JDK / SDK / NDK / Gradle | 17 / 34 / r26d / 8.5+ |
| VCS | Git | ≥ 2.40 |
| 脚本 | Python + fonttools | ≥ 3.10 |

## 目录结构（规划）

详见主 Plan 的 `## 目录结构` 章节，本仓库当前已存在：
- `dev-plans/`（v0/v1 全量 + 顶层）
- `dev-process/`（本目录）

后续在 v0/T02 之后会陆续出现：`CMakeLists.txt` / `cmake/` / `third_party/` / `src/` / `android/` / `assets/` / `tools/` / `docs/`

## 与本仓库的对应

- **静态契约**（要做什么）：[`../dev-plans/`](../dev-plans/)
- **动态记录**（做到哪了）：本目录
- **代码与资源**：仓库根其他目录（v0/T02 起逐步出现）

---

> 本快照仅作仓库内只读参考。修改主 Plan 须通过 CodeBuddy plan tool，修改后 Agent 会重新生成本文件。
