# [v1 / T14] Telemetry 基础版

| 项 | 值 |
| --- | --- |
| 所属版本 | v1-mvp |
| 预计工时 | 4-6 h |
| 前置依赖 | T07 |
| 涉及目录 | `src/util/telemetry.{h,cpp}` / `src/util/thermal.h` |

## 目标
实现本地遥测：每帧采集帧时间/操作计数/活动工具，1Hz 落盘 JSONL，按日切分文件，保留最近 7 天；纯本地、无网络权限。

## 主要产出
- `src/util/telemetry.h/.cpp`：`Telemetry { record(sample) / flush() / setEnabled(bool) }`
- `src/util/thermal.h`：`IThermalReader` 接口（桌面实现读 `/proc/cpuinfo` 或返回 -1，Android 实现 v3 补）
- 遥测文件落盘到 `getAppDataDir()/logs/YYYY-MM-DD.jsonl`
- App 主循环每帧 record，1Hz 节流写盘
- 退出时 flush

## 验收标准 (DoD 大纲)
- [ ] 运行 1 分钟后 `getAppDataDir()/logs/` 出现今日 JSONL 文件
- [ ] 每行是合法 JSON，字段完整（timestampMs/frameTimeMs/cpuPercent/...）
- [ ] 写盘节流为 1Hz，I/O 不影响主循环（同步写但每秒 1 次）
- [ ] 跨日时自动切分到新文件
- [ ] 启动时清理 7 天前的旧文件
- [ ] `setEnabled(false)` 后立即停止采集与写盘
- [ ] 编译通过 / 无新 lint 警告

## 备注
- 决策点：CPU 占用怎么测？Windows 用 `GetProcessTimes`，Android 留 v3
- batteryTemp 与 thermalStatus 在桌面统一返回 -1，Android 在 v3/T14 补
- 调试面板可视化曲线（debug_overlay）属 v3
- 隐私文档：`docs/TELEMETRY.md` 在 v3 写完整版，本任务先打 placeholder

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
