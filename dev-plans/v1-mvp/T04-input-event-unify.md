# [v1 / T04] InputEvent 统一

| 项 | 值 |
| --- | --- |
| 所属版本 | v1-mvp |
| 预计工时 | 3-4 h |
| 前置依赖 | T03 |
| 涉及目录 | `src/util/input_event.h` / `src/app.cpp` |

## 目标
把 SDL 鼠标 / 触摸 / 笔事件归一化为统一的 `InputEvent` 流，工具层只面对一种事件类型，桌面默认压感 1.0。

## 主要产出
- `src/util/input_event.h`：`InputEvent { x, y, pressure, phase, source }`
- `src/app.cpp` 中事件分发：`SDL_MOUSEBUTTON*` / `SDL_FINGER*` / `SDL_PenEvent`（备用）→ `InputEvent`
- `EventDispatcher` 类（含 `subscribe(handler)` 接口，供工具与画布视图监听）

## 验收标准 (DoD 大纲)
- [ ] Windows 鼠标点击/拖动可生成完整 Begin/Move/End 流
- [ ] 触摸事件归一化：单指对应 InputEvent，多指由 T13 处理
- [ ] 桌面 pressure 默认 1.0；Android 笔事件透传 pressure（T13 验证）
- [ ] 事件坐标为窗口像素坐标（画布坐标变换在画布视图层做）
- [ ] ImGui 占用焦点时（如鼠标在面板上），事件不能漏给工具层
- [ ] 编译通过 / 无新 lint 警告

## 备注
- ImGui 焦点判断用 `ImGui::GetIO().WantCaptureMouse`
- 决策点：事件分发用回调还是 polling？建议回调（订阅模式），简洁
- 多点触控（缩放）不属于本任务，留 T13

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
