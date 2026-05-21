# [v0 / T02] CMake 跨平台骨架

| 项 | 值 |
| --- | --- |
| 所属版本 | v0-foundation |
| 预计工时 | 3-4 h |
| 前置依赖 | T01 |
| 涉及目录 | `/`（根 CMakeLists） / `cmake/` / `src/` |

## 目标
建立单一 CMake 工程，同时驱动 Windows 桌面与 Android（NDK）目标，无第三方库时即可生成空目标。

## 主要产出
- `CMakeLists.txt`（根，定义 project / C++17 / 输出目录 / 平台分支）
- `cmake/deps.cmake`（占位，T03 填充）
- `cmake/android.toolchain.cmake`（NDK 工具链桥接，引用 NDK 自带的）
- `src/app.cpp` + `src/app.h`（最小骨架：`int App::run() { return 0; }`）
- `src/platform/desktop/main.cpp`（最小骨架：`int main() { return App().run(); }`）
- `.gitignore`（排除 build/、third_party/ 内构建产物）

## 验收标准 (DoD 大纲)
- [ ] `cmake -S . -B build -G Ninja` 在 Windows 上零警告通过
- [ ] `cmake --build build` 生成 `pixelstar.exe`（或 `pixelstar`）
- [ ] 运行可执行文件正常退出（exit code 0）
- [ ] CMakeLists 内有清晰的平台分支（`if(ANDROID) ... else() ...`）
- [ ] C++17 标准、警告级别 `/W4` 或 `-Wall -Wextra`、`-Werror=return-type`

## 备注
- 暂不接 SDL2/ImGui，T04 才接
- Android 目标本任务**不要求能构建**，只要 CMake 能 configure 通过即可（避免 NDK 强依赖）
- 决策点：是否启用 LTO？建议 Release 启用，Debug 不启用

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
