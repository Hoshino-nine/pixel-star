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
