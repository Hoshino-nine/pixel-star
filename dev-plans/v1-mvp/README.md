# v1-mvp · 最小可玩版

> **对应主 Plan 里程碑**：`canvas-render-pipeline` + `mvp-tools-and-ui` + `png-export-and-android-shell`
> **版本目标**：双端可运行的最小像素画 App—— 单帧绘画 + 4 个工具 + 调色板 + 撤销 + PNG 导出 + 本地遥测 + 主题 JSON 化
> **退出条件**：
> - Windows 桌面与 Android（API 29+）均能启动
> - 用户能用铅笔/橡皮/吸管/填充桶画出一张 512×512 像素画
> - 能撤销/重做（默认 100 步）
> - 能从预设调色板（PICO-8/NES/GameBoy）选色
> - 双指可缩放/平移画布
> - 能导出 PNG 到设备相册（Android 通过 MediaStore）
> - `assets/themes/default_dark.json` 控制 UI 视觉，无硬编码
> - `getAppDataDir()/logs/` 有 JSONL 遥测日志按日切分
> - 18 个子任务全部验收通过

## 任务状态表

### Block A：Canvas & Render（对应 canvas-render-pipeline）

| ID | 任务 | 预计工时 | 前置 | 状态 |
| --- | --- | --- | --- | --- |
| T01 | [Canvas 数据模型](T01-canvas-data-model.md) | 4-6 h | v0 完成 | pending |
| T02 | [GL Renderer 与 Shader](T02-gl-renderer.md) | 6-8 h | T01 | pending |
| T03 | [Dirty Rect 上传管线](T03-dirty-rect-pipeline.md) | 4-6 h | T02 | pending |

### Block B：Tools & UI（对应 mvp-tools-and-ui）

| ID | 任务 | 预计工时 | 前置 | 状态 |
| --- | --- | --- | --- | --- |
| T04 | [InputEvent 统一](T04-input-event-unify.md) | 3-4 h | T03 | pending |
| T05 | [铅笔 & 橡皮工具](T05-pencil-eraser-tools.md) | 4-6 h | T04 | pending |
| T06 | [吸管 & 填充桶工具](T06-eyedropper-fill-tools.md) | 4-6 h | T05 | pending |
| T07 | [History 撤销栈](T07-history-undo-redo.md) | 4-6 h | T05 | pending |
| T08 | [theme.json 加载器](T08-theme-json-loader.md) | 3-4 h | T04 | pending |
| T09 | [widgets 基础组件](T09-widgets-foundation.md) | 4-6 h | T08 | pending |
| T10 | [底部工具栏](T10-bottom-toolbar.md) | 4-6 h | T09 | pending |
| T11 | [侧边抽屉](T11-side-drawer.md) | 4-6 h | T09 | pending |
| T12 | [调色板面板](T12-palette-panel.md) | 3-4 h | T11 | pending |
| T13 | [画布手势（缩放/平移）](T13-canvas-view-gesture.md) | 4-6 h | T04, T03 | pending |
| T14 | [Telemetry 基础版](T14-telemetry-basic.md) | 4-6 h | T07 | pending |

### Block C：Export & Android（对应 png-export-and-android-shell）

| ID | 任务 | 预计工时 | 前置 | 状态 |
| --- | --- | --- | --- | --- |
| T15 | [PNG 导出](T15-png-export.md) | 3-4 h | T14 | pending |
| T16 | [Android Gradle 壳](T16-android-gradle-shell.md) | 6-8 h | T15 | pending |
| T17 | [JNI MediaStore 桥接](T17-jni-mediastore-bridge.md) | 4-6 h | T16 | pending |
| T18 | [MVP 双端验收](T18-mvp-acceptance.md) | 4-6 h | T17 | pending |

## 推进顺序

T01 → T02 → T03 → T04 → T05 → T06 → T07 → T08 → T09 → T10 → T11 → T12 → T13 → T14 → T15 → T16 → T17 → T18

部分任务（T07/T08, T11/T12 等）逻辑上独立，可在用户许可下并行细化 Plan，但仍按上面序号编号。

## 完成后

- 主 Plan 中 `canvas-render-pipeline` / `mvp-tools-and-ui` / `png-export-and-android-shell` 三个里程碑同时标记 done
- `dev-process/STATE.md` 切换活跃版本为 `v2-standard`
- 触发 v2 子任务文档生成
