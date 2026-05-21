# [v1 / T18] MVP 双端验收

| 项 | 值 |
| --- | --- |
| 所属版本 | v1-mvp |
| 预计工时 | 4-6 h |
| 前置依赖 | T17 |
| 涉及目录 | 全栈 |

## 目标
完成 MVP 端到端体验联调：双端可启动、能完整画完一张像素画并导出 PNG；遥测日志正确落盘；APK 与桌面 exe 可分发。补齐文档，交付 v1。

## 主要产出
- 端到端测试脚本/手测清单：`docs/MVP-CHECKLIST.md`
- `docs/BUILD.md` 第一版：Windows + Android 构建步骤
- 修复联调中发现的 bug（必然有）
- README.md 项目根的第一版（项目简介 + 构建入口 + dev-plans 索引）

## 验收标准 (DoD 大纲)
- [ ] **桌面端流程**：启动 → 画 50 笔 → 撤销 5 步 → 重做 3 步 → 切换工具 → 切色 → 导出 PNG → 用其他软件打开正确
- [ ] **Android 端流程**：APK 安装 → 启动 → 同上 → 导出后在相册可见
- [ ] **遥测验收**：双端运行 5 分钟后 logs 目录有今日 JSONL，每行字段完整
- [ ] **主题验收**：手动改 `default_dark.json` 中一个颜色，重启 App 立即生效
- [ ] **性能验收**：1024×1024 画布连续画线 60 秒，桌面端帧时间 ≤ 16 ms 稳定，无明显卡顿
- [ ] **APK 体积**：≤ 12 MB
- [ ] **桌面 exe 体积**：≤ 8 MB
- [ ] `tools/check_deps.ps1 -Stage mvp` 全绿
- [ ] 编译无 warning，read_lints 无新增

## 备注
- 联调中发现的 bug 写入 `dev-process/tasks/v1-T18-mvp-acceptance/execution-log.md`
- 完成验收后：主 Plan 中 `canvas-render-pipeline` / `mvp-tools-and-ui` / `png-export-and-android-shell` 三个里程碑同时标 done
- `dev-process/STATE.md` 切换活跃版本为 v2-standard，触发 v2 全量子任务文档生成
- 风险：MVP 阶段总是会发现一些跨任务的小问题，本任务预算 4-6 小时是补漏时间

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
