# 通用约定

## 1. 任务文档骨架模板

每个 `Txx-*.md` 在创建时遵循此结构（细节由 Step 2 细化 Plan 阶段补充进 `## 实现细节`）：

```markdown
# [vX / Txx] 任务名

| 项 | 值 |
| --- | --- |
| 所属版本 | vX-xxx |
| 预计工时 | X 小时 |
| 前置依赖 | (上游任务 ID 列表) |
| 涉及目录 | src/xxx/, ... |

## 目标
（一两句话）

## 主要产出
- 文件 1
- 文件 2

## 验收标准 (DoD 大纲)
- [ ] 标准 1
- [ ] 编译通过 / 无新 lint 警告

## 备注
（关键风险或决策点）

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
> 完成验收后追加"## 实施回顾"小节。
```

## 2. 5 步循环工作流

| Step | 触发 | Agent 动作 |
| --- | --- | --- |
| 1 | 用户说"开始 vX/Txx" | 读 `STATE.md` + 任务文档 |
| 2 | 进入 Plan 模式 | 出细化 Plan（含具体文件改动、接口契约） |
| 3 | 用户确认 → building | 创建 `dev-process/tasks/<id>/plan.md`；更新 `STATE.md` 状态→in_progress；`timeline.md` 追加；执行编码；中频追加 `execution-log.md` |
| 4 | 完成执行 | 写 `self-check.md`；`STATE.md` 状态→awaiting-acceptance |
| 5 | 用户验收 | 通过：写 `acceptance.md` + 更新 vX README 状态表 + STATE 切到下一任务；不通过：反馈记入 acceptance.md，回 Step 3 |

## 3. check_deps SOP（前置依赖检查）

每个子任务执行前必须运行：

```powershell
tools/check_deps.ps1 -Stage <mvp|standard|full>
```

脚本职责：
1. 校验系统级工具最低版本（CMake/Ninja/MSVC/Git/JDK/NDK/SDK/Python）
2. 校验 `third_party/` 下 submodule 是否齐全
3. 按 Stage 校验对应阶段第三方库（如 full 才查 giflib/libwebp/miniz）
4. 缺失项必须先补齐再继续编码

详细依赖清单见主 Plan 的"依赖清单与前置检查"章节，或 `dev-process/plan-snapshot.md`。

## 4. execution-log 写入频率（中频）

- 每个**有意义的步骤完成后**追加一条
- 例：完成一组接口定义、跑通一次编译、解决一个具体问题、做出一个关键决策
- **不必每次工具调用都记**；也**不能等到全部完成才记**
- 格式：`- [HH:MM] <动作描述>（关联文件/决策/坑点）`

## 5. 自检清单（self-check.md 内容）

```markdown
# Self Check - vX/Txx

## DoD 勾选
- [x] 标准 1（实际证据：xxx）
- [x] 标准 2

## 编译
- Windows desktop: PASS / FAIL（错误摘要）
- Android: PASS / FAIL / SKIP（本任务不涉及）

## Lint
- read_lints 输出：无新增警告 / 有 N 条（已修复 / 已记录）

## 风险与遗留
- ...

## 待用户验收 → STATE.md 已切换为 awaiting-acceptance
```

## 6. 验收记录（acceptance.md 内容）

```markdown
# Acceptance - vX/Txx

| 项 | 值 |
| --- | --- |
| 验收时间 | YYYY-MM-DD HH:MM |
| 结果 | PASS / FAIL |

## 用户反馈
（用户的原话或要点）

## 后续动作
- PASS：dev-plans/vX/README.md 状态表已更新；STATE.md 切到下一任务
- FAIL：需修正项列表 → 回 Step 3
```

## 7. Git 提交规范（约定式提交 Conventional Commits）

```
<type>(<scope>): <subject>

[optional body]

Refs: vX/Txx
```

- type：`feat` / `fix` / `chore` / `docs` / `refactor` / `perf` / `test` / `build`
- scope：`core` / `render` / `ui` / `io` / `platform` / `util` / `android` / `cmake` / `dev-plans` / `dev-process`
- 每个子任务建议 1 个提交（除非中途有阶段性可独立提交的成果）
- **Agent 不主动 commit**，由用户决定时机

## 8. 主 Plan 与版本里程碑映射

| 主 Plan Todo | dev-plans 目录 |
| --- | --- |
| bootstrap-cross-platform | v0-foundation/（T01-T05） |
| canvas-render-pipeline | v1-mvp/（T01-T03） |
| mvp-tools-and-ui | v1-mvp/（T04-T14） |
| png-export-and-android-shell | v1-mvp/（T15-T18） |
| layers-shapes-mirror-picker + sprite-sheet-export | v2-standard/（进入时生成） |
| frame-animation-system + pxs-and-aseprite-io + android-polish | v3-full/（进入时生成） |
| performance-and-release | v4-release/（进入时生成） |

完成一个版本所有子任务 → 对应主 Plan 里程碑 Todo 才能标记 done。

## 9. Plan Artifact 与落地文档的关系（重要）

IDE 的 Plan Artifact 槽位是**单实例工作台**，不是进度档案柜。本项目采用如下分工：

| 角色 | 内容 | 谁来维持 |
| --- | --- | --- |
| **Plan Artifact**（系统槽位） | 当前正在做的**那一个子任务**的细化 Plan | Step 2 用 `plan_create` 写入；Step 4/5 完成后即"用完即弃"，等待下个子任务覆盖 |
| **`dev-process/plan-snapshot.md`** | 主 Plan 全文落地副本，**永久参照** | 主 Plan 有变更时同步刷新；平日只读 |
| **`dev-process/plan-snapshot.json`** | 主 Plan 10 个里程碑的 todolist + 我们维护的 `local_status` 字段（`pending` / `in_progress` / `done`） | **每个子任务 Step 5 验收通过时同步更新 `local_status`** |
| **`dev-plans/vX/README.md` 状态表** | 该版本下所有子任务的状态 | Step 5 验收通过时勾选 |
| **`dev-process/STATE.md`** | 当前活跃任务指针 + 最近事件 | Step 3 building 时切 in_progress；Step 4 切 awaiting-acceptance；Step 5 切下一任务 |

**5 步循环对 Plan Artifact 的处理**：

| Step | Plan Artifact 动作 | dev-process 同步动作 |
| --- | --- | --- |
| 1 用户说"开始 vX/Txx" | （读，不动） | 读 STATE / plan-snapshot / 任务文档 |
| **2 出细化 Plan** | **`plan_create` 把 Txx 细化版作为新 Plan Artifact**，覆盖前一个 | 不变 |
| 3 用户确认 → building | `plan_update status=building` | 写 `tasks/<id>/plan.md`（细化 Plan 永久副本，防 Artifact 被下个子任务覆盖时丢失）；STATE→in_progress；timeline 追加 |
| 3' 执行编码 | （不动） | 中频追加 `execution-log.md` |
| 4 完成自检 | `plan_update status=finished` | 写 `self-check.md`；STATE→awaiting-acceptance |
| 5 用户验收 | （等待下个子任务覆盖） | 写 `acceptance.md`；勾选 `dev-plans/vX/README.md`；**如该子任务是版本最后一个 → 同步 `plan-snapshot.json` 把对应里程碑 `local_status` 翻 done**；STATE 切下一任务 |

**进度真相恢复路径**（任何 Agent 任何时候）：

1. 读 `dev-process/STATE.md` → 知道当前活跃子任务
2. 读 `dev-process/plan-snapshot.json` → 知道 10 个主 Plan 里程碑的 `local_status`
3. 读 `dev-plans/vX/README.md` 状态表 → 知道当前版本内所有子任务状态
4. 读 `dev-process/tasks/<当前任务>/` 全部文件 → 知道当前子任务进度细节
5. **不依赖** Plan Artifact 的当前状态（它可能是上一任务 finished、可能是当前任务 building，都不影响以上 4 项的真相性）

## 10. 脚本文件编码约定（v0/T01 经验沉淀）

**所有含**中文字符**的脚本与配置文件必须按以下编码保存：**

| 文件类型 | 强制编码 | 原因 |
| --- | --- | --- |
| `.ps1` (PowerShell) | **UTF-8 with BOM** (`EF BB BF`) | PowerShell 5.1 在系统区域为 GB/Shift-JIS 的 Windows 上，默认按系统 ANSI 编码解析无 BOM 的脚本；遇到 UTF-8 字节序列会乱码，可能破坏字符串/哈希字面量闭合，产生神秘的 "Unexpected token" / "hash literal incomplete" 报错。 |
| `.sh` (Bash) | UTF-8 (无 BOM 即可) | Bash 自带 UTF-8 友好；加 BOM 反而会让 `#!/usr/bin/env bash` shebang 失效。 |
| `.md` / `.json` / `.cmake` / `.toml` / `.yaml` | UTF-8 (无 BOM 即可) | 现代工具链通用约定。 |
| `.cpp` / `.h` / `.hpp` / `.cxx` | UTF-8 with BOM **或** 无 BOM 均可，但**全项目统一** | MSVC 对无 BOM UTF-8 源码在 GB 系统区域下也会按 GB 解析；建议加 BOM 或在 CMake 里加 `/utf-8` 编译选项（T02 会处理）。 |

**验证方法**（PowerShell）：
```powershell
$bytes = [IO.File]::ReadAllBytes('path/to/file.ps1')
'{0:X2} {1:X2} {2:X2}' -f $bytes[0], $bytes[1], $bytes[2]
# 应输出 'EF BB BF' 表明 UTF-8 BOM 存在
```

**批量修复**（一次性给所有 `.ps1` 加 BOM）：
```powershell
Get-ChildItem -Recurse -Filter '*.ps1' | ForEach-Object {
    $bytes = [IO.File]::ReadAllBytes($_.FullName)
    if ($bytes[0] -ne 0xEF -or $bytes[1] -ne 0xBB -or $bytes[2] -ne 0xBF) {
        [IO.File]::WriteAllBytes($_.FullName, [byte[]](0xEF,0xBB,0xBF) + $bytes)
    }
}
```

**为何不简单"避免中文"？**——本项目开发者母语为中文，所有用户面向的脚本提示信息（安装指引、错误说明）都用中文显著降低使用摩擦；强制英文化得不偿失。这条约定就是为了让中文友好与跨平台脚本可执行性共存。
