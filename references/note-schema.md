# 笔记 Schema：目录 / properties / 模板 / 命名

## 目录结构

```
<VAULT_PATH>/
└── Projects/<项目名>/
    ├── _index.md               # 项目 MOC：全部笔记列表 + 状态（见 project-moc.md）
    └── 2026-09-07-<slug>.md    # 笔记：预览确认后直接写入，status: reviewed
```

- 新笔记经预览确认后，直接写入 `Projects/<项目>/`，`status: reviewed`（写入即正式，无暂存区）。

## properties（YAML frontmatter）

```yaml
---
type: conversation-digest
project: <项目名>
source: session-<会话ID>
date: 2026-09-07
status: reviewed
tags:
  - agent
  - <项目标签>
---
```

字段约束：
- `type` 固定 `conversation-digest`（用于 Dataview/查询过滤）。
- `source` 必填，用于幂等查重（`check_duplicate.sh --source`）。
- `status` 固定 `reviewed`（写入即正式；写入前由第 5 步预览确认把关）。
- `tags` 至少含 `agent`；项目标签与 `_index.md` 一致。

## 正文模板（模块化，按需选用）

```markdown
# <主题标题>

> 一句话摘要 | <YYYY-MM-DD> | 项目：<项目名>

## 背景与事实
- 事实条目（附来源：用户原话或消息序号）

## 关键决定
- 决定条目

## 行动项
- [ ] 行动条目（含负责人/截止时间，如有）

## 学习要点          ← 按对话内容选用
- 概念 / 原理 / 方法论要点

## 资料与链接        ← 按对话内容选用
- 文献 / URL / 文件路径

## 灵感与想法        ← 按对话内容选用
- 想法条目

## 待讨论问题        ← 按对话内容选用
- 问题条目

## 产出物
- 名称（路径）

## 关联笔记
- [[_index]] ← 项目索引
```

**使用原则**：小节从模块库中按需组合，**不要求全部出现，也不限于这些**；
对话是什么样就按什么样组织（如纯学习对话可以只有「学习要点 + 资料与链接」）。
每个条目尽量附来源（用户原话/消息序号），见 `extract-rules.md` 标注规则。

## 命名规则

- 文件名：`YYYY-MM-DD-HHMM-<slug>.md`（写在 `Projects/<项目>/` 内，无需项目前缀）。
- `slug`：取标题前 12~20 个字符，替换 `/\:*?"<>|` 与空白为 `-`，中文直接保留。
- 冲突：目标文件名已存在 → 追加 `-2`、`-3` 递增序号，并在两篇笔记正文互相 `[[wikilink]]` 关联。

## 写入失败兜底

若脚本写入失败（路径不可写等），整理结果必须完整呈现在回复中，并标注「未写入，内容如上」。
