# PixelStar 全局事件时间线

> 追加式记录，最新在底部。每条 1-2 行，含时间戳。
> 本文件与 `STATE.md "最近事件"` 互补：STATE 只保留最近 10 条作快速查看，本文件保留全部。

---

- `2026-05-21 14:40` **体系建立**：dev-plans/ 顶层 README + conventions + v0(6 文件) + v1(19 文件) 共 27 个静态契约骨架文档生成完毕；dev-process/ 含 STATE/plan-snapshot.{md,json}/timeline/handoffs/tasks 共 6 项动态归档体系初始化完毕。等待用户下达 `开始 v0/T01`。
- `2026-05-21 15:06` **远程仓库初始化**：本地 `git init -b main` + `.gitignore`（排除 `.codebuddy/` / `.agents/` / `skills-lock.json` / 构建产物）+ commit `f31d6ed` 共 34 文件 1393 inserts；绑定 `origin = https://github.com/Hoshino-nine/pixel-star.git`；远程已存在 `64ad669 Initial commit (LICENSE)`，用 `git pull --rebase --allow-unrelated-histories` 线性合并后推送成功。当前 HEAD `1397e7a` 与 `origin/main` 同步。
