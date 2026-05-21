# [v1 / T08] theme.json 加载器

| 项 | 值 |
| --- | --- |
| 所属版本 | v1-mvp |
| 预计工时 | 3-4 h |
| 前置依赖 | T04 |
| 涉及目录 | `src/ui/` / `assets/themes/` |

## 目标
实现 `ITheme` 与 `UiSpec`：从 `assets/themes/*.json` 读取颜色/字号/间距/圆角等设计 token，运行时应用到 ImGuiStyle，可热切换；为后期接入 Google Stitch 设计稿铺路。

## 主要产出
- `src/ui/theme.h`：`UiSpec` 结构体 + `ITheme` 接口
- `src/ui/theme.cpp`：JSON 加载 + `applyToImGui()` 实现
- `assets/themes/default_dark.json`：完整的默认深色主题
- `assets/themes/README.md`：theme.json schema 文档

## 验收标准 (DoD 大纲)
- [ ] App 启动时从 `assets/themes/default_dark.json` 加载
- [ ] 加载失败时回落到 ImGui 默认 dark theme，不崩溃
- [ ] 切换 theme 调用 `loadFromJson` + `applyToImGui` 即可立即生效
- [ ] schema 至少覆盖：5 种颜色、3 级圆角、4 级间距、2 级字号
- [ ] 主题文件 JSON 5 友好（带注释）暂不支持，纯标准 JSON
- [ ] 后续 panel/widget 代码都从 `Theme::current().spec()` 取值，禁止硬编码
- [ ] 编译通过 / 无新 lint 警告

## 备注
- ImGui 颜色用 `ImVec4` 4 通道 0-1 浮点；JSON 中可用十六进制字符串（如 `"#1A1A1E"`）便于设计稿对齐
- 决策点：是否预留 light theme 文件？建议本任务先建一个空的 `default_light.json` 占位，v3 再补
- Stitch 接入工具（`tools/stitch_to_theme.py`）属于 v3，本任务只确保 schema 设计能容纳 Stitch 输出的常见 token

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
