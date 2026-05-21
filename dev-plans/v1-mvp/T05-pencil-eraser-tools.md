# [v1 / T05] 铅笔 & 橡皮工具

| 项 | 值 |
| --- | --- |
| 所属版本 | v1-mvp |
| 预计工时 | 4-6 h |
| 前置依赖 | T04 |
| 涉及目录 | `src/core/tools/` |

## 目标
实现铅笔工具（按当前色绘制）与橡皮工具（清空像素），含 Bresenham 直线连点（避免拖动时漏点）。

## 主要产出
- `src/core/tools/tool.h`：`ITool` 接口（`onEvent(InputEvent, Canvas, History)`）
- `src/core/tools/pencil_tool.cpp`：铅笔，Bresenham 连点；记录 dirty
- `src/core/tools/eraser_tool.cpp`：橡皮，等同铅笔但写入 `0x00000000`
- `App` 持有当前激活工具的 `std::unique_ptr<ITool>`，初始为 Pencil

## 验收标准 (DoD 大纲)
- [ ] 鼠标点击单点像素正确着色
- [ ] 拖动连续移动时形成连续直线（无漏点）
- [ ] 移动速度快时（每帧跨 ≥ 5 像素）依然连续
- [ ] 橡皮可清除已绘制像素，背景透明（棋盘可见）
- [ ] 工具切换接口预留：`App::setActiveTool("pencil"|"eraser")`
- [ ] dirty rect 正确扩展，渲染下一帧反映改动
- [ ] 编译通过 / 无新 lint 警告

## 备注
- History 接入留到 T07，本任务的工具 onEvent 可暂不入栈（先打 TODO）
- 决策点：笔刷大小 1px 还是支持 1-8px？MVP 阶段先 1px，方块刷形 v2 再做
- 镜像绘制（X/Y 对称轴）属于 v2，本任务不做

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
