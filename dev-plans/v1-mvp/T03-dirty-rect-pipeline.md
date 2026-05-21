# [v1 / T03] Dirty Rect 上传管线

| 项 | 值 |
| --- | --- |
| 所属版本 | v1-mvp |
| 预计工时 | 4-6 h |
| 前置依赖 | T02 |
| 涉及目录 | `src/render/` / `src/core/canvas.cpp` |

## 目标
实现脏矩形跟踪与合并算法，每帧仅通过一次 `glTexSubImage2D` 上传变化区域，避免全图传输；为后续工具笔触的 60Hz 流畅性打底。

## 主要产出
- `src/render/dirty_rect.h/.cpp`：`DirtyRectTracker { addRect / merge / drain }`
- `Canvas` 内置 `DirtyRectTracker` 成员
- `CanvasTexture::uploadDirty(canvas)`：从 canvas drain 出 dirty rect 并增量上传

## 验收标准 (DoD 大纲)
- [ ] 多个 rect 能正确合并为最小包围盒（或保留为多个矩形列表，二选一并写测试）
- [ ] 全 canvas 修改时退化为单次全图上传（不能比直接全图慢）
- [ ] 在 1Hz 测试下：随机修改 100 个 1x1 像素，dirty rect 总面积 ≤ 全图 1%
- [ ] 单元测试 ≥ 4 个：单 rect、相邻 rect 合并、远离 rect、全图覆盖
- [ ] 修改 1 个像素时只上传不超过 32×32 的小块（合并阈值）
- [ ] 编译通过 / 无新 lint 警告

## 备注
- 算法策略：先用"包围盒合并"（简单粗暴，MVP 够用），v4 阶段再考虑"四叉树或多矩形列表"
- 决策点：合并阈值（合并 vs 拆分的临界面积）建议 16×16 作为初值
- 这是性能与发热的核心管线，写完后做一次 frame time 基准（用 v0/T05 日志输出）

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
