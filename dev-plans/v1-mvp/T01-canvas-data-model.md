# [v1 / T01] Canvas 数据模型

| 项 | 值 |
| --- | --- |
| 所属版本 | v1-mvp |
| 预计工时 | 4-6 h |
| 前置依赖 | v0 全部完成 |
| 涉及目录 | `src/core/` |

## 目标
建立平台无关的 `Canvas` 与 `Layer` 数据结构（MVP 单图层即可，但接口预留多图层），作为后续渲染、工具、IO 的统一数据中心。

## 主要产出
- `src/core/canvas.h/.cpp`：尺寸、像素缓冲（`std::vector<uint32_t>` RGBA8）、dirty rect 标记接口
- `src/core/layer.h/.cpp`：单层数据；MVP 阶段只需 1 层但接口齐全
- `src/core/palette.h/.cpp`（基础版，仅承载 `std::vector<uint32_t>` + 当前索引）

## 验收标准 (DoD 大纲)
- [ ] `Canvas canvas(512, 512)` 默认构造可用
- [ ] `setPixel(x,y,rgba)` / `getPixel(x,y)` 接口正确
- [ ] dirty rect 在像素改动时正确扩展（提供 `getAndClearDirty()` 接口）
- [ ] 内存占用：512×512 RGBA = 1 MB；预留 `reserve()` 提升上限到 1024×1024
- [ ] 单元测试至少 3 个：基本 set/get、dirty rect 合并、越界 set 不崩
- [ ] 编译通过 / 无新 lint 警告

## 备注
- 决策点：`Canvas` 持有像素 vs `Layer` 持有像素？建议 `Layer` 持有，`Canvas` 持有图层列表，MVP 仅 1 个 Layer
- 不要在本任务实现混合模式（属于 v2）
- 内部用 RGBA8（4 字节），调色板索引模式（GL_R8）作为 v4 优化候选

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
