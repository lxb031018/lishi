# 粒时

> 每做完一件具体的事情, 就提交一下吧。

灵感来自 git —— 把每天主动做的、有意义的事, 像 git commit 一样记录下来。
下班、放学、周末、假期这些完全由自己掌控的时间, 想到什么就立即开始, 做完就提交。
提交后休息 5 分钟, 然后开始新的一件事。

不是番茄钟的替代品, 是 git 精神的随身版。

## 平台

- Android ✅
- iOS 🚧 (工程预留, 暂未启用构建)

## 开发

```bash
flutter pub get
flutter run              # 接到 Android 设备/模拟器调试
flutter analyze          # 静态分析
flutter test             # 单元 + Widget 测试
```

## 仓库约定

- main 分支可直接 push (单人开发, 配了防 force push / 防删分支保护)
- 不走 PR 流程, 每次 commit 一次只做一件事
- 提交信息参考 `.gitmessage` 模板 (Conventional Commits 风格)
- CI 会在 push 后自动跑 analyze / test / build-android, 不强制门禁
