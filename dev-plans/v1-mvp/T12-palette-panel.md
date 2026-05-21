# [v1 / T12] 调色板面板

| 项 | 值 |
| --- | --- |
| 所属版本 | v1-mvp |
| 预计工时 | 3-4 h |
| 前置依赖 | T11 |
| 涉及目录 | `src/ui/palette_panel.cpp` / `src/core/palette.cpp` / `assets/palettes/` |

## 目标
调色板面板（左侧抽屉）：预设 Tab（PICO-8/NES/GameBoy/自定义）+ 颜色网格 + 当前色高亮 + 添加颜色按钮（占位）。

## 主要产出
- `src/ui/palette_panel.h/.cpp`：`PalettePanel::draw(Palette&)`
- `src/core/palette.cpp` 扩展：`loadFromJson(path)` / `merge(other)` / `setActive(rgba)` / `activeIndex()`
- `assets/palettes/pico8.json`：16 色
- `assets/palettes/nes.json`：54 色
- `assets/palettes/gameboy.json`：4 色

## 验收标准 (DoD 大纲)
- [ ] 抽屉打开后展示当前调色板，颜色以 8 列网格排布
- [ ] 当前色显示明显边框高亮
- [ ] 点击颜色立即切换为活动色（铅笔/橡皮立即生效）
- [ ] Tab 切换不同预设可生效
- [ ] 加载预设 JSON 失败时回落到内置 8 色，不崩
- [ ] 颜色色块大小适配触摸（≥36dp）
- [ ] 编译通过 / 无新 lint 警告

## 备注
- 决策点：自定义 Tab 内容怎么持久化？MVP 阶段用 `getAppDataDir()/custom_palette.json`
- HSV 拾取器属 v2，本任务"添加颜色"按钮先占位 disabled
- 风险：JSON 中颜色用十六进制字符串（"#FF6B6B"），与 theme.json 一致

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
