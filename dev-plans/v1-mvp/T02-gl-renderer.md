# [v1 / T02] GL Renderer 与 Shader

| 项 | 值 |
| --- | --- |
| 所属版本 | v1-mvp |
| 预计工时 | 6-8 h |
| 前置依赖 | T01 |
| 涉及目录 | `src/render/` |

## 目标
封装 OpenGL 渲染：上传 Canvas 像素到纹理、绘制棋盘背景 + 画布纹理 + 网格，桌面端能看到一张默认棋盘 + 居中的纯色画布。

## 主要产出
- `src/render/gl_renderer.h/.cpp`：渲染入口 `render(const Canvas&, const Camera&)`
- `src/render/canvas_texture.h/.cpp`：封装 `GLuint` + 像素上传接口
- `src/render/shaders/`：GLSL 300 es 着色器（顶点+片元）
  - `canvas.vert/.frag`：渲染画布纹理（NEAREST 滤波保持像素锐利）
  - `checker.frag`：棋盘背景（uv 计算）
  - `grid.frag`（可选）：像素网格叠加，缩放 ≥ 8x 时显示

## 验收标准 (DoD 大纲)
- [ ] 桌面端启动后看到深色棋盘背景 + 居中的画布矩形（默认填充浅灰）
- [ ] 缩放 ≥ 8x 时显示像素网格（次任务可补，本任务可仅打底）
- [ ] 像素采样为 NEAREST，绝不模糊
- [ ] 着色器编译错误能在控制台输出 GLSL log
- [ ] 切换全屏 / 缩放窗口画布保持居中（基础 Camera 接口）
- [ ] GL 调用零错误（每帧 `glGetError()` 在 Debug 下检查）

## 备注
- Camera 暂为最小：`{ float zoom; vec2 pan; }`，T13 才接入手势
- 桌面用 OpenGL 3.3 Core，Android 用 GLES 3.0；着色器写 `#version 300 es` 加 desktop 兼容预处理
- 决策点：是否本任务就引入 GL 状态缓存？建议否（MVP 不需要，留 v4）
- 风险：N/A（Windows 上 GL 3.3 几乎都支持）

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
