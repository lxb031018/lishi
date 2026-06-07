# 启用 main 分支保护 (GitHub) — 逐屏教程

> 适用: https://github.com/lxb031018/lishi
> 目标: 让 main 只能通过 PR + CI 全绿才能合入, 自己也不能直接 push
> 当前 CI 只有 3 个 job (iOS 暂不做, 见 `ci.yml` 末尾注释)

---

## 0. 前置确认 (10 秒)

打开这个 URL 看 CI 是不是真的跑过:

```
https://github.com/lxb031018/lishi/actions
```

你应该看到 1 个绿色的 ✅ "CI" run, 时间在 4 分钟左右 (iOS job 拉得最慢)。

**为什么必须先跑一次**: GitHub 状态检查的下拉框只列出"历史上跑过至少一次"的 job 名。
没跑过的 job 你搜都搜不到。

---

## 1. 进入分支保护设置页

URL 直接打这个 (省得在菜单里翻):

```
https://github.com/lxb031018/lishi/settings/branches
```

或者手动点:

1. 进仓库主页
2. 顶上标签栏点 **Settings** (不是 Profile Settings, 是仓库自己的)
3. 左边栏找 **Code and automation** → **Branches**
4. 看到 "Branch protection rules" 区块, 右边点绿色的 **Add rule** / **Add branch protection rule**

---

## 2. 填表 — 逐项说明

下面按页面从上到下的顺序讲每一项。**粗体**是这一项要选什么。

### 2.1 Branch name pattern

> **填: `main`**

精确匹配这一条分支, 不影响其它分支 (后面你开 `feat/*` 都不受这个规则约束)。

> 💡 如果想保护一组分支, 用通配符, 比如 `release/*` 会匹配 `release/1.4.x`。
> 但 main 一般精确写就行, 别图省事写 `*`。

---

### 2.2 勾选清单 (从上到下)

#### ✅ Require a pull request before merging

> **勾上, 展开后:**
> - ☑ **Require approvals** → 填 `1`
> - ☑ **Dismiss stale pull request approvals when new commits are pushed** (勾上, 推荐)
> - ☐ Require review from Code Owners (暂时用不到, 跳过)

**含义**: 必须有人批准你的 PR 才能合入, 而且你后续 push 新 commit 后, 之前的 approval 自动作废,
得让人再 review 一次。这避免你"提 PR 后偷偷加东西"。

#### ✅ Require status checks to pass before merging

> **勾上, 展开后:**
> - ☑ **Require branches to be up to date before merging** (勾上, 推荐)
> - **Status checks that are required** 那个搜索框 → 输入下面 3 个名字, **每个点一次加进去**:
>
>   | 输入的 job 名 (完全匹配) | 含义 |
>   |---|---|
>   | `Analyze & format` | 静态分析 + 格式检查 |
>   | `Unit & widget tests` | 单元测试 + Widget 测试 |
>   | `Build Android (debug APK)` | Android Debug 包能编出来 |

> ⚠️ **重要**: 名字是 job 的 `name:` 字段, 不是 workflow 文件名, 也不是 step 名。
> 大小写、空格、连字符都要一模一样。
>
> 找不到? 回去看 `docs/BRANCH_PROTECTION.md` 第 5 节,
> 或者打开 `.github/workflows/ci.yml` 对照 `name:` 字段。

#### ✅ Require conversation resolution before merging

> **勾上**

**含义**: PR 里所有 review 评论必须被手动 resolve (点 "Resolve conversation") 才能合入。
防止你 review 完不看意见就 merge。

#### ✅ Do not allow bypassing the above settings

> **勾上, 强烈推荐**

**含义**: 即使你是仓库 owner, 也不能用 "管理员绕过" 那个开关。
这一条是给未来的你上保险——某天赶工时想偷懒也得走流程。

#### ✅ Restrict who can push to matching branches

> **勾上, 选: `Maintainers`**

**含义**: 只有 maintainer 角色的人能 (绕过 PR) 直接 push,
普通 contributor 根本看不到 push 按钮。
对你一个人开发来说无所谓, 但勾上没坏处。

#### ✅ Allow force pushes

> **❌ 不要勾** (默认就是关)

**含义**: 勾了之后任何人都能 `git push -f`, 把别人合入的历史覆盖掉。
永远不要勾。

#### ✅ Allow deletions

> **❌ 不要勾** (默认就是关)

**含义**: 勾了之后 main 都能被删, 仓库就废了。
永远不要勾。

---

## 3. 提交

拉到页面最下面, 绿色按钮 **Create** / **Save changes** → 点一下。

页面会跳回分支列表, 你应该能看到一条新规则:

```
main
Require pull request reviews before merging
Require status checks to pass before merging
...
```

---

## 4. 验证一下 (5 秒)

### 4.1 试一下直推 main, 应该被拦

```bash
cd D:\AllCodes\lishi

# 先在 README 随便加一行, commit 上去
echo "" >> README.md
git add README.md
git commit -m "test: verify branch protection"

# 试着直推
git push origin main
```

你有两个可能:

- **我们之前装的 pre-push hook 拦了** → 看到那段红框 "❌ 禁止直接 push 到 main", 说明本地 hook 正常。
- **hook 没装** (你跳过 install-hooks.sh 了) → 推送会被 GitHub 拒绝, 返回
  `remote: error: GH006: Protected branch update failed for refs/heads/main.`

两种都说明保护生效。✅

### 4.2 试一下走 PR, 应该能合

```bash
git checkout -b test/verify-protection
git push -u origin test/verify-protection
```

然后到 https://github.com/lxb031018/lishi/compare/main...test/verify-protection 开 PR。

PR 页面上你会看到:

- 底部状态检查 4 个 job 在跑 (可能需要 4 分钟, iOS 最慢)
- 全部 ✅ 之后出现 "Merge pull request" 绿色按钮
- 点击 merge → Squash 模式 → 确认 → 分支被合入 main

合入后, GitHub 会提示 "Delete branch", 顺手删掉, 保持仓库干净。

---

## 5. 常见踩坑

| 现象 | 原因 | 解决 |
|---|---|---|
| 状态检查下拉框搜不到 `Build Android (debug APK)` | CI 还没跑过, 或 iOS 那个 job 还在但 Android 没成功 | 等 5 分钟, 或去 Actions 手动 re-run 一次 |
| PR 一直显示 "Waiting for status checks" | iOS macos-latest runner 排队 (高峰期可能要等 10 分钟) | 耐心等, 或者把 iOS job 改成只在 push 到 main 触发, PR 不跑 |
| 提交 PR 后报 "Review required" 卡住 | 你是唯一维护者, 没法给自己 approve | Settings → Branches → 把 "Do not allow bypassing..." 关掉, 临时; 合完 PR 再开回来 |
| 误把 secrets 推上去了 | 见 `docs/BRANCH_PROTECTION.md` 第 8 节 | 立刻去 GitHub Settings → Secrets 删, 然后 `git filter-branch` / BFG 清历史 |
| `git push` 报 `403` | 你的 PAT 没开 `repo` scope, 或 SSH key 没加 | 重新生成 token, 或在 GitHub → Settings → SSH and GPG keys 加 key |

---

## 6. 验收清单 (给自己打个分)

按顺序做完下面 5 步, 全绿就 OK:

- [ ] https://github.com/lxb031018/lishi/settings/branches 里看到 main 的规则
- [ ] 直推 main 被拦 (本地 hook 或 GitHub 报错都行)
- [ ] PR 页能看到 4 个状态检查, 跑完都 ✅
- [ ] squash merge 一个测试 PR 成功
- [ ] merge 后能删掉那个 feature 分支
