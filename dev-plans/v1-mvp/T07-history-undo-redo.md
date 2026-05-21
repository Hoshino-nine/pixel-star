# [v1 / T07] History 撤销栈

| 项 | 值 |
| --- | --- |
| 所属版本 | v1-mvp |
| 预计工时 | 4-6 h |
| 前置依赖 | T05（铅笔已能产生改动） |
| 涉及目录 | `src/core/` |

## 目标
实现命令模式撤销/重做栈，默认上限 100 步；笔触命令用 dirty rect + before/after 像素行程编码（RLE）压缩存储。

## 主要产出
- `src/core/command.h`：`ICommand { apply / revert / memoryFootprint }`
- `src/core/commands/stroke_command.cpp`：聚合一次按下到抬起的笔触改动（含 dirty rect + before/after RLE）
- `src/core/commands/fill_command.cpp`：填充命令（同结构）
- `src/core/history.h/.cpp`：环形栈，按内存预算/步数双重限制
- 工具的 onBegin 创建命令，onEnd 提交 history

## 验收标准 (DoD 大纲)
- [ ] Ctrl+Z / Ctrl+Y 可撤销/重做铅笔笔触和填充
- [ ] 撤销栈达 100 步后丢弃最旧条目
- [ ] 内存预算上限 64 MB 时不会 OOM（在大画布连续操作时验证）
- [ ] 撤销后画布、dirty rect、UI 一致
- [ ] 单元测试：连续 200 笔后撤销 50 次，状态正确
- [ ] 编译通过 / 无新 lint 警告

## 备注
- 决策点：内存预算 vs 步数限制谁优先？建议两者取最小（任一触发就丢弃）
- RLE 压缩可用 `std::vector<std::pair<uint32_t color, uint32_t runLen>>`
- 撤销 UI 入口（按钮）属 T10 底部工具栏
- 风险：填充命令的 before 数据可能很大（整块连通区），用 RLE 后通常压缩比 50× 以上

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
