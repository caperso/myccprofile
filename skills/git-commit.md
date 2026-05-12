---
name: git-commit
description: 按 Conventional Commits + 工单号 scope 规范生成 git commit（英文 subject,适用于所有仓库）
type: skill
---

# git-commit Skill

为任意仓库生成符合 Conventional Commits 规范的 git commit。

## 触发场景

用户说「提交」「commit」「生成提交」「帮我 commit」等。

## 提交信息格式

```
<type>(<scope>): <subject>
```

说明：
- 单行即可,通常不加 body(除非用户明确要写长说明)
- **不要**手写 MR/PR 链接、issue 引用尾注——很多平台合并时会自动追加
- subject 用**英文**、**小写开头**、**祈使句**、**末尾不加句号**
- 整行建议控制在 72 字符以内

## type 取值

按以下优先级选择,优先使用**当前仓库 `git log` 中实际出现过**的 type：

| type | 含义 |
|------|------|
| `feat` | 新功能/增强 |
| `fix` | Bug 修复 |
| `chore` | 依赖升级、配置调整、杂项 |
| `refactor` | 代码重构(不改变外部行为) |
| `docs` | 文档 |
| `test` | 测试 |
| `style` | 代码格式(非 CSS) |
| `perf` | 性能优化 |
| `build` | 构建系统 |
| `ci` | CI/CD 配置 |
| `revert` | 回滚提交 |

**重要**：执行步骤 1 后,若发现当前仓库只用一个子集(例如只有 feat/fix/chore),就严格限制在该子集内,不要擅自引入仓库没出现过的 type。

## scope 取值规则

scope 的选取**必须**先观察当前仓库历史,按仓库实际习惯来。常见几种风格：

1. **工单号风格**(如 `feat(SIR-6983919897): xxx`、`fix(CTRIP-4114): xxx`、`feat(ARCS-2873): xxx`)
   - 该仓库主流使用 Jira/任务平台工单号作 scope
   - 前缀大小写保持工单原样,数字部分完整保留
2. **纯数字任务号**(如 `feat(6927685572): xxx`)
   - 该仓库用数字任务号
3. **模块/包名风格**(如 `feat(auth): xxx`、`fix(api): xxx`)
   - 该仓库用业务模块 / 包名 / 目录名
4. **无 scope**(如 `feat: xxx`)
   - 该仓库普遍不写 scope,或确实找不到合适的

### 如何确定 scope

按以下顺序：
1. 看 `git log --oneline -30` 中 scope 的主流写法,沿用同风格
2. 如是工单号风格：
   - 优先**问用户要工单号**
   - 或从当前分支名推断(很多仓库分支名即工单号)
   - 或从改动文件 / PR 描述里找工单引用
3. 如是模块名风格：看改动集中在哪个模块/目录,取该名
4. 找不到就省略 scope

## subject 写法

- **英文**、**小写开头**、**祈使句**(add/update/fix/remove…)、**末尾不加句号**
- 聚焦 "做了什么",不要写 "为什么"(why 留给 PR/MR 描述)
- 示例：
  - ✅ `feat(SIR-6983919897): update booking image URL handling`
  - ✅ `fix: update ticket and condition ui`
  - ✅ `chore(deps): upgrade typescript to 5.4`
  - ✅ `refactor(auth): extract token refresh into hook`
  - ❌ `feat: Updated the booking image URL.`(首字母大写 + 过去式 + 句号)
  - ❌ `fix: 修复行李选择问题`(不要用中文)

## 执行流程

按以下步骤执行,**禁止跳步**：

### 1. 并行收集状态
同一个消息内并行执行以下命令,用于确定仓库风格和改动范围：
- `git status`(不加 `-uall`)
- `git diff`(查看所有已暂存 + 未暂存的改动)
- `git log --oneline -30`(**关键**：学习该仓库的 type/scope/subject 风格)
- `git branch --show-current`(用于从分支名推断 scope)

### 2. 分析改动 + 沿用仓库风格
- 基于 diff 判断 type(feat/fix/chore/refactor…)
- 对照 `git log` 最近提交归纳 scope 风格:
  - 如果历史里 scope 都是工单号 → 这次也用工单号(主动问用户 / 从分支名推断)
  - 如果历史里都是模块名 → 这次用模块名
  - 如果历史里都不写 scope → 这次也可不写
- 英文 subject,小写开头,聚焦"做了什么"

### 3. 安全检查
- 绝不包含 `.env`、`*.pem`、`credentials.*`、`id_rsa` 等敏感文件;若发现在暂存区要警示用户
- 用 `git add <具体文件>` 添加,避免 `git add -A` / `git add .`
- 不要 `--amend` 之前的提交(除非用户明确要求)
- 不要 `--no-verify`
- 不要改 git 配置

### 4. 并行执行提交
同一个消息内并行：
- `git add <具体文件列表>`
- `git commit -m "$(cat <<'EOF' ... EOF)"`(用 HEREDOC 确保格式)
- 随后串行跑 `git status` 确认提交成功

### 5. 钩子失败处理
- pre-commit hook 失败时,commit 实际上**没有**发生 → 不要用 `--amend`(会改上一条旧提交)
- 正确流程：修复问题 → `git add` 修复后的文件 → 新建一条 commit
- 若 lint / format / types 检查失败,先跑仓库对应的修复命令(如 `npm run lint:fix`、`prettier --write`)再提交

## 示例场景

### 示例 1：仓库用工单号风格
`git log` 显示 `feat(SIR-xxx): ...`、`fix(ORI-xxx): ...`
→ 主动问用户工单号,或从分支名 `6927685572` 推断
→ `feat(6927685572): integrate bundle fees for klm compliance`

### 示例 2：仓库用模块名风格
`git log` 显示 `feat(auth): ...`、`fix(api): ...`
→ 根据改动目录选 scope
→ `fix(api): handle 429 rate limit retries`

### 示例 3：仓库不写 scope
`git log` 显示 `feat: ...`、`fix: ...`,几乎没有 scope
→ 也不写 scope
→ `feat: add dark mode toggle`

### 示例 4：依赖升级
→ `chore(deps): bump react to 18.3`
→ 或无 scope: `chore: upgrade dependencies`

## 禁止项

- ❌ 不要在 commit message 里写 PR/MR 链接(如 `(xivart/origami!691) [!691](url)`)——合并时平台自动追加
- ❌ 不要写 `Co-Authored-By: Claude`、`🤖 Generated with Claude Code` 之类尾注
- ❌ 不要用中文 subject
- ❌ 不要引入当前仓库 `git log` 中从未出现的 type 风格
- ❌ 不要用 `-uall`、不要 `--no-verify`、不要擅自 `--amend`
- ❌ 没和用户确认前不要 `git push`
- ❌ 不要擅自用 `git add -A` / `git add .`,用具名文件列表
