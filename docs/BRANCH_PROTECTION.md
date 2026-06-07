# Branch 保护 & 工作流建议

> 这份是规范建议。等你把仓库推到 GitHub / GitLab / Gitee 时, 照这份在
> 仓库设置里勾一下就行。本地裸仓库也建议先按 "分支命名约定" 走。

---

## 1. 分支命名约定

| 类型         | 格式                      | 例子                       | 用途                 |
| ------------ | ------------------------- | -------------------------- | -------------------- |
| 主干         | `main`                    | `main`                     | 永远可发布, 受保护   |
| 长期维护     | `release/*`               | `release/1.4.x`            | 历史版本补丁         |
| 功能开发     | `feat/*`                  | `feat/wechat-login`        | 新功能               |
| Bug 修复     | `fix/*`                   | `fix/cart-crash`           | 修 bug               |
| 热修复       | `hotfix/*`                | `hotfix/1.4.1-login-fail`  | 线上紧急修复         |
| 重构/杂项    | `chore/*` 或 `refactor/*` | `chore/upgrade-flutter-3`  | 升级/重构/脚手架     |
| 个人试验     | `<name>/*`                | `lxb/explore-riverpod`     | 一次性探索, 随时丢   |

**规则**:

- 分支名全部小写, 用 `-` 连接, 不用空格/下划线
- 跟一个 issue/工单号更佳: `feat/123-wechat-login`
- `main` 上不能直接 push, 必须走 PR/MR

---

## 2. 主分支 (`main`) 保护规则 (平台无关的核心清单)

| 规则                              | 建议值              | 说明                                          |
| --------------------------------- | ------------------- | --------------------------------------------- |
| 禁止 force push                   | ✅ 开启             | 不然别人 `git push -f` 就能改历史              |
| 禁止删除分支                      | ✅ 开启             | 防止误删 `main`                               |
| 必须通过 PR/MR 才能合入           | ✅ 开启             | 合入前先 review                               |
| 必须的 approval 数                | ≥ 1 (团队 ≤ 5 人)  | 至少一个不是作者本人                          |
| 合入前必须 CI 全绿                | ✅ 开启             | analyze + test + build                        |
| 禁止直推                          | ✅ 开启             | 即使有权限也得走流程                           |
| 限制谁能 push 到 main             | 仅 maintainer       | 普通人连 push 按钮都看不到                     |
| 要求分支最新 (linear history)     | ✅ 开启             | 强制 rebase / squash, 历史干净                |
| 要求 commit 信息规范              | 可选, 但强烈推荐   | 配合 `.gitmessage` 模板                       |

---

## 3. GitHub 开启方式 (Settings → Branches → Branch protection rules → Add rule)

```
Branch name pattern:  main

☑ Require a pull request before merging
    ☑ Require approvals: 1
    ☑ Dismiss stale pull request approvals when new commits are pushed
☑ Require status checks to pass before merging
    ☑ Require branches to be up to date before merging
    Status checks: 选 ci 里跑的那几个 job (analyze / test / build)
☑ Require conversation resolution before merging
☑ Do not allow bypassing the above settings
☑ Restrict who can push to matching branches
    → 勾 maintainer / owner
☑ Allow force pushes   ✗  (保持关闭)
☑ Allow deletions      ✗  (保持关闭)
```

---

## 4. GitLab 开启方式 (Settings → Repository → Protected branches)

```
Branch:  main

Allowed to push:        Maintainers
Allowed to merge:       Maintainers + Developers
Allowed to unprotect:   Maintainers

☑ Require push to be reviewed and approved before merging
    Approvals required: 1
☑ Status checks must succeed
    (在 CI/CD 里给需要的 job 配 "Allowed to fail = false")
☑ Prevent pushing secret files
☑ Branch must be up-to-date before merging
☑ Squash commits when merge request is accepted
```

---

## 5. CI 最低要求 (Flutter)

`main` 受保护时, 至少跑这几个 job, 否则合入没意义:

| Job         | 命令                                          | 失败即阻止合入 |
| ----------- | --------------------------------------------- | -------------- |
| analyze     | `flutter analyze --fatal-infos --fatal-warnings` | ✅             |
| format      | `dart format --set-exit-if-changed .`         | ✅ (可选)      |
| test        | `flutter test --coverage`                     | ✅             |
| build apk   | `flutter build apk --debug`                   | ✅ (可选)      |
| build ios   | `flutter build ios --debug --no-codesign`     | ✅ (可选)      |

> 建议先做 `analyze` + `test` 两个 job, 跑稳了再加成 `build`。
> 不然 build 失败会让你 PR 一直红, 体验差。

---

## 6. 提交流程参考 (团队 SOP)

```
1. 从 main 拉新分支
   git checkout main
   git pull
   git checkout -b feat/123-wechat-login

2. 写代码 + 测试
   flutter test
   flutter analyze

3. 提交 (走模板, 一次只做一件事)
   git add -p            # 按 hunk 暂存, 别一把梭
   git commit            # 弹出 .gitmessage 模板

4. 推送 + 开 PR/MR
   git push -u origin feat/123-wechat-login
   # 去 GitHub/GitLab 开 PR, 关联 issue, 找人 review

5. CI 绿了 + 至少 1 个 approval → squash merge
6. 删远程分支
```

---

## 7. 本地先能做的 (不依赖平台)

```bash
# 启用 commit 信息模板
git config commit.template .gitmessage

# 启用 rebase 而不是 merge 来同步 main (历史更干净)
git config --global pull.rebase true

# 保护 main 不被误 push
git config --global branch.main.pushRemote no-remote
# 或者装个 pre-push hook, main 上 push 就报错
```

---

## 8. 红色警戒 (千万别做)

- ❌ 在 `main` 上直接 `git commit` + `git push`
- ❌ 用了 `git push -f` 覆盖已经合入的 main 历史
- ❌ 把 keystore / `key.properties` / `GoogleService-Info.plist` 这种 secret 提交
- ❌ 一个 commit 改了 30 个文件, 信息写 "更新" 两个字的
- ❌ 把 `pubspec.lock` 在自己本地是改过的状态, 但没在 commit message 里说升级了啥
