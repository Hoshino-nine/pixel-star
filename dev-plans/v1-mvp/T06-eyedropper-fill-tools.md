# [v1 / T06] 吸管 & 填充桶工具

| 项 | 值 |
| --- | --- |
| 所属版本 | v1-mvp |
| 预计工时 | 4-6 h |
| 前置依赖 | T05 |
| 涉及目录 | `src/core/tools/` |

## 目标
实现吸管（点击像素后切回上一工具并设当前色）与填充桶（扫描线 flood fill）。

## 主要产出
- `src/core/tools/eyedropper_tool.cpp`：吸取颜色后调用 `Palette::setActive(rgba)` 并切回上一工具
- `src/core/tools/bucket_tool.cpp`：扫描线 flood fill，生成单条 `FillCommand`（覆盖 dirty rect 与改动行程）

## 验收标准 (DoD 大纲)
- [ ] 吸管点击后画布被吸取颜色变为活动色
- [ ] 吸管使用后自动切回上一工具（pencil/eraser 等）
- [ ] 填充桶在连通区域内填充（4 邻接），透明区与有色区视作不同
- [ ] 1024×1024 全画布填充耗时 ≤ 50 ms（大致基准，写 LOG_I 输出）
- [ ] 填充不会爆栈（用迭代式扫描线，非递归）
- [ ] 编译通过 / 无新 lint 警告

## 备注
- 决策点：4-邻接 vs 8-邻接 flood fill？MVP 用 4-邻接（标准做法）
- 容差暂设为 0（精确匹配 RGBA），v2 可加阈值
- 填充耗时受 dirty rect 影响：填完一次性 mark dirty 整块即可

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
