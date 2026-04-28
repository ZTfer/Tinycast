---
alwaysApply: true
scene: git_message
---

# Git Commit Message 规范

## 提交格式

```
<type>(<scope>): <summary>

<正文：描述本次变更的背景与动机>

Agent-Task: <原始任务描述或任务 ID>
Agent-Decision: <关键设计决策及理由>
Agent-Limitation: <已知局限或后续 TODO>
```

## 格式说明

### 第一行：标题
- `<type>`: 变更类型，如 feat、fix、docs、style、refactor、test、chore 等
- `<scope>`: 影响范围（可选），如 auth、ui、api 等
- `<summary>`: 简短描述，使用祈使句，首字母小写，不以句号结尾

### 第二行：空行
- 必须保留空行分隔标题与正文

### 第三行起：正文
- 详细描述本次变更的背景与动机
- 解释"为什么"做这个变更，而非"做了什么"（标题已说明）
- 每行不超过 72 个字符

### Agent 元数据（必填）
- `Agent-Task`: 原始任务描述或任务 ID，用于追溯需求来源
- `Agent-Model`: AI 模型标识，记录生成此变更的模型版本
- `Agent-Decision`: 关键设计决策及其理由，说明为何选择此方案
- `Agent-Limitation`: 已知局限性或后续 TODO，提醒未来改进方向

## 示例

```
feat(auth): add JWT token refresh mechanism

当用户 token 过期时自动刷新，避免频繁重新登录。
采用双 token 机制（access + refresh），提升安全性。

Agent-Task: 实现自动 token 刷新功能
Agent-Decision: 选择滑动窗口过期策略而非固定过期，提升用户体验
Agent-Limitation: 未处理并发刷新场景，可能导致多个 refresh 请求
```