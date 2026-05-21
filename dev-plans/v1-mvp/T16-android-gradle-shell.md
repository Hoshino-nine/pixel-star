# [v1 / T16] Android Gradle 壳

| 项 | 值 |
| --- | --- |
| 所属版本 | v1-mvp |
| 预计工时 | 6-8 h |
| 前置依赖 | T15 |
| 涉及目录 | `android/` |

## 目标
建立 Android Gradle 工程，使用 `org.libsdl.app.SDLActivity` 子类作为入口，externalNativeBuild 链入根 CMake，输出 `pixelstar-debug.apk` 可在 Android 10+ 安装运行（先不做 PNG 导出，先能启动渲染空 ImGui 窗口）。

## 主要产出
- `android/build.gradle`（项目级）
- `android/app/build.gradle`（minSdk=29, targetSdk=34, abi=arm64-v8a + armeabi-v7a）
- `android/app/CMakeLists.txt`（引用根 CMake 编译 `libpixelstar.so`）
- `android/app/src/main/AndroidManifest.xml`（无 INTERNET 权限；声明 `WRITE_EXTERNAL_STORAGE` 仅在 < API 29 兼容；含 SDLActivity 入口配置）
- `android/app/src/main/java/com/pixelstar/PixelStarActivity.java`（继承 SDLActivity）
- `android/gradlew` + `gradle/wrapper/`（Gradle 8.5 wrapper）
- `android/app/src/main/res/`（应用图标 + 启动画面占位）

## 验收标准 (DoD 大纲)
- [ ] `./gradlew assembleDebug` 在 Windows 上成功
- [ ] APK 体积 ≤ 12 MB（含 libSDL2.so + libpixelstar.so 两个 ABI）
- [ ] adb install 后可启动，看到 ImGui demo window
- [ ] 横竖屏切换不崩溃
- [ ] logcat 中能看到 v0/T05 的 LOG_I 输出（通过 logcat tag "PixelStar"）
- [ ] 触摸事件能进入工具流（铅笔可画一两笔）
- [ ] 编译无新 lint 警告（含 Java 与 CMake）

## 备注
- 决策点：是否启用 R8 / Proguard？MVP 阶段关闭（避免 Java 类反射问题）
- SDL2 Android 项目结构有官方 template，可直接参考 SDL/android-project 子目录
- 风险：Android 10+ Scoped Storage，PNG 导出留到 T17（MediaStore）
- 不做：签名 release APK、Google Play 发布相关（属 v4）

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
