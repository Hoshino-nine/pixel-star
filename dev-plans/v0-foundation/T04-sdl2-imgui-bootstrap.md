# [v0 / T04] SDL2 + ImGui 引导

| 项 | 值 |
| --- | --- |
| 所属版本 | v0-foundation |
| 预计工时 | 4-6 h |
| 前置依赖 | T03 |
| 涉及目录 | `src/app.cpp` / `src/app.h` / `src/render/` |

## 目标
跑通 SDL2 创建窗口、初始化 OpenGL 上下文、ImGui 接入并渲染一个空窗口，桌面端可见 "PixelStar" 标题。

## 主要产出
- `src/app.cpp`（升级版：SDL_Init → 创建窗口 → 初始化 GL → ImGui_ImplSDL2_Init / ImGui_ImplOpenGL3_Init → 主循环）
- `src/app.h`（App 类完整声明，含 init / mainLoop / shutdown）
- `src/render/gl_context.h/.cpp`（封装 GL 上下文初始化）
- 主循环中渲染 ImGui demo window（验证管线通畅）

## 验收标准 (DoD 大纲)
- [ ] Windows 上 `pixelstar.exe` 启动后弹出标题为 "PixelStar" 的窗口
- [ ] 默认显示 ImGui demo window（验证渲染通畅）
- [ ] 窗口可缩放，关闭按钮正常
- [ ] 主循环帧率合理（vsync on，约 60 fps）
- [ ] 退出无内存泄漏（debug 编译下检查）
- [ ] 编译无新增 warning

## 备注
- ImGui backend 用 `imgui_impl_sdl2.cpp` + `imgui_impl_opengl3.cpp`（直接从 third_party/imgui/backends 引用）
- GL loader 选择：建议直接用 SDL2 的 `SDL_GL_GetProcAddress`，不引第三方 loader
- 决策点：是否本任务就启用 docking？建议启用（便于后续抽屉式 UI）
- 风险：Windows 上不同显卡驱动 GL 兼容性差异，先要求 GL 3.3 Core

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
