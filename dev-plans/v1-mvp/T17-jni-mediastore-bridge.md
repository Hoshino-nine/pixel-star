# [v1 / T17] JNI MediaStore 桥接

| 项 | 值 |
| --- | --- |
| 所属版本 | v1-mvp |
| 预计工时 | 4-6 h |
| 前置依赖 | T16 |
| 涉及目录 | `src/platform/android/` / `android/app/src/main/java/com/pixelstar/` |

## 目标
通过 JNI 把 PNG 字节流写入 Android 相册（MediaStore.Images），完成 Android 端的 PNG 导出闭环；首次需要时申请相应权限（API 29+ 不需权限可写 Pictures 目录，但分享 Intent 需要 ContentResolver）。

## 主要产出
- `src/platform/android/platform_android.cpp`：`PlatformAndroid::exportToGallery(bytes, name)` JNI 调用
- `src/platform/android/jni_bridge.h`：JNI helper 宏
- `android/app/src/main/java/com/pixelstar/NativeBridge.java`：`exportPngToGallery(byte[] data, String filename)` 静态方法（用 MediaStore.Images.Media）
- `IPlatform` 接口的桌面实现（直接写文件）与 Android 实现并存

## 验收标准 (DoD 大纲)
- [ ] Android 设备上点击"导出"后图片出现在系统相册中
- [ ] 文件名 / 时间正确
- [ ] 桌面端"导出"逻辑不受影响（仍走 tinyfiledialogs）
- [ ] 导出失败时返回错误码并 toast 提示
- [ ] JNI 引用正确释放（无 LocalRef 泄漏）
- [ ] 不需要任何 dangerous permission（API 29+ MediaStore.RELATIVE_PATH 写 Pictures 子目录无需 WRITE_EXTERNAL_STORAGE）
- [ ] 编译通过 / 无新 lint 警告

## 备注
- 决策点：导出后是否自动触发分享 Intent？MVP 不做，留 v3
- 测试设备至少跨 Android 10 / 12 / 14 验证（用户手头有什么用什么）
- 风险：MediaStore.RELATIVE_PATH 在 API 29 才稳定，更老 OS 走传统路径——但 minSdk=29 已避开

---
> 详细实现要点、接口契约、风险分析将在 Step 2 细化 Plan 阶段补充进"## 实现细节"小节。
