# [v1 / T09] widgets 基础组件

| 项 | 值 |
| --- | --- |
| 所属版本 | v1-mvp |
| 预计工时 | 4-6 h |
| 前置依赖 | T08 |
| 涉及目录 | `src/ui/widgets/` |

## 目标
封装 `PsButton` / `PsPanel` / `PsDrawer` / `PsSlider` 4 个统一组件，所有上层面板只调这些 widget；后期 Stitch 设计稿调整只改 widget 实现，无需改面板代码。

## 主要产出
- `src/ui/widgets/ps_button.h/.cpp`
- `src/ui/widgets/ps_panel.h/.cpp`（容器类，承担背景 + 圆角 + padding）
- `src/ui/widgets/ps_drawer.h/.cpp`（侧边滑出抽屉，含动画 state）
- `src/ui/widgets/ps_slider.h/.cpp`（横向滑块，可显示数值）

## 验收标准 (DoD 大纲)
- [ ] 4 个 widget 全部从 `Theme::current().spec()` 读样式
- [ ] 各自有最小 demo 展示（在 dev demo window 中或临时 panel）
- [ ] 大触摸目标（按钮高度 ≥ 44dp，sliders 滑轨高度 ≥ 24dp）
- [ ] 适配横竖屏（按钮自适应宽度）
- [ ] PsDrawer 可控制开/关，含简单滑动动画（150ms）
- [ ] 编译通过 / 无新 lint 警告

## 备注
- 实现思路：包装 `ImGui::Button` / `ImGui::Begin` 等，不重新发明 ImGui 控件，只做样式聚合 + 触摸尺寸保证
- 决策点：是否引入 `PsIcon` 组件？建议本任务先不做，T10 工具栏需要时再加
- DPI scaling：默认按 ImGui FontGlobalScale 处理，移动端在 v3 再细调

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
