# [v1 / T11] 侧边抽屉

| 项 | 值 |
| --- | --- |
| 所属版本 | v1-mvp |
| 预计工时 | 4-6 h |
| 前置依赖 | T09 |
| 涉及目录 | `src/ui/side_drawer.cpp` |

## 目标
实现左侧/右侧滑出抽屉容器，承载调色板、（v2）图层、（v3）帧时间线等面板；带平滑动画与外部点击关闭。

## 主要产出
- `src/ui/side_drawer.h/.cpp`：`SideDrawer { setSide(Left|Right), open(), close(), draw(content) }`
- 与 PsDrawer widget 联动；驻留容器 + 内容回调

## 验收标准 (DoD 大纲)
- [ ] 调用 `open()` 后从屏幕边缘平滑滑入（150ms 缓动）
- [ ] 抽屉外点击 / 按 ESC 关闭
- [ ] 抽屉内可放置任意 ImGui 内容
- [ ] 同时只能开 1 个抽屉（左右互斥）
- [ ] 抽屉宽度：移动端 280-320dp，桌面 360dp
- [ ] 不阻挡底部工具栏
- [ ] 编译通过 / 无新 lint 警告

## 备注
- 决策点：动画用线性还是 ease-out？建议 ease-out（更自然）
- ImGui 实现侧滑：直接用 `ImGui::SetNextWindowPos` 每帧更新 X 坐标
- 风险：手势滑动关闭（拖动抽屉边缘）属于体验加分项，留 v3

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
