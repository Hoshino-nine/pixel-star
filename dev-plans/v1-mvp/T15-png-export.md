# [v1 / T15] PNG 导出

| 项 | 值 |
| --- | --- |
| 所属版本 | v1-mvp |
| 预计工时 | 3-4 h |
| 前置依赖 | T14 |
| 涉及目录 | `src/io/png_exporter.cpp` / `src/ui/dialogs/export_dialog.cpp` |

## 目标
集成 stb_image_write，把当前画布导出为 PNG；桌面写到用户选择的路径，Android 通过 IPlatform 接口（实装在 T17）。

## 主要产出
- `src/io/png_exporter.h/.cpp`：`PngExporter::write(const Canvas&, std::vector<uint8_t>& out)` 与 `writeToFile(canvas, path)`
- `src/ui/dialogs/export_dialog.h/.cpp`：最简版本（格式选择器 + 文件名输入 + 导出按钮）
- 桌面端通过 `tinyfiledialogs` 或 SDL 自带文件选择？决策点见备注
- `IPlatform::exportToGallery` 接口加入（Android 实现留 T17）

## 验收标准 (DoD 大纲)
- [ ] 桌面：从底部工具栏"导出"打开对话框 → 选择路径 → 生成的 PNG 用 Windows 照片应用打开正确
- [ ] 透明像素正确导出为 RGBA8 透明
- [ ] 1024×1024 画布导出耗时 ≤ 200 ms
- [ ] 导出成功 / 失败有用户提示（toast 或 dialog）
- [ ] PngExporter 单元测试：写入到内存 buffer 再读出像素一致
- [ ] 编译通过 / 无新 lint 警告

## 备注
- 决策点：桌面文件选择器用什么？最轻方案是 SDL_ShowSaveFileDialog（SDL3 才有，SDL2 无）→ 引入 tinyfiledialogs（单文件，~50 KB）
- Android 不弹文件选择器，直接走 MediaStore（T17）
- 风险：tinyfiledialogs 跨平台，但若与 ImGui 焦点冲突，需在调用时暂停主循环

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
