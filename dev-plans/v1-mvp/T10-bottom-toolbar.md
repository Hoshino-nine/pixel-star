# [v1 / T10] 底部工具栏

| 项 | 值 |
| --- | --- |
| 所属版本 | v1-mvp |
| 预计工时 | 4-6 h |
| 前置依赖 | T09 |
| 涉及目录 | `src/ui/bottom_toolbar.cpp` |

## 目标
固定底部工具栏（高 72dp）：左侧 4 个工具按钮（铅笔/橡皮/吸管/填充桶）+ 中间撤销/重做 + 右侧"打开调色板""导出"。激活工具高亮。

## 主要产出
- `src/ui/bottom_toolbar.h/.cpp`：`BottomToolbar::draw(App&)`
- 工具按钮图标（暂用 ImGui drawlist 自绘 16×16 像素风图标，或纯文字 emoji 占位）
- 与 `App::setActiveTool` 联动；与 `History::canUndo/canRedo` 联动

## 验收标准 (DoD 大纲)
- [ ] 工具栏固定在窗口底部，高度恰好 72dp（用 theme spacing 量算）
- [ ] 4 个工具按钮可点击切换；激活工具按钮显示高亮（边框或背景色）
- [ ] 撤销/重做按钮根据 History 状态启用/禁用
- [ ] "打开调色板"按钮触发 `PalettePanel` drawer 切换
- [ ] "导出"按钮触发 `ExportDialog`（先放占位，T15 实装）
- [ ] 仅由 PsButton/PsPanel 构成（验证 widget 抽象是否够用）
- [ ] 编译通过 / 无新 lint 警告

## 备注
- 决策点：图标用 emoji 占位还是自绘？emoji 跨字体不一致，自绘 16×16 简单图形（铅笔/方块橡皮等）更可控
- 长按提示（tooltip）暂不做，留 v3
- 风险：工具栏高度叠加 SafeArea（Android 导航栏）需在 T16 微调

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
