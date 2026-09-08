#!/usr/bin/env bash
# write_note.sh — 把整理好的内容直接写入 Obsidian vault 的 Projects/<项目>/ 目录。
#
# 用法:
#   write_note.sh --project <项目名> --title <标题> \
#                 --body <正文文件路径> [--source <会话ID>] [--tags <逗号分隔>]
#
# 行为:
#   - 自动创建 Projects/<项目> 目录（vault 根目录不存在时按提示报错）
#   - 文件名: Projects/<项目>/YYYY-MM-DD-HHMM-<slug>.md
#   - 文件冲突时自动追加 -2 / -3 序号，并写入 wikilink 关联
#   - 输出实际写入的绝对路径
#
# 退出码: 0=成功写入; 2=参数缺失; 3=vault 路径不可用

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=config.sh
source "${SCRIPT_DIR}/config.sh"

PROJECT=""
TITLE=""
BODY=""
SOURCE=""
TAGS="agent"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2 ;;
    --title)   TITLE="$2";   shift 2 ;;
    --body)    BODY="$2";    shift 2 ;;
    --source)  SOURCE="$2";  shift 2 ;;
    --tags)    TAGS="$2";    shift 2 ;;
    *) echo "未知参数: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$PROJECT" || -z "$TITLE" || -z "$BODY" ]]; then
  echo "错误: 缺少必要参数 --project / --title / --body" >&2
  exit 2
fi

if [[ ! -f "$BODY" ]]; then
  echo "错误: 正文文件不存在: $BODY" >&2
  exit 2
fi

# vault 根目录校验
if [[ ! -d "$VAULT_PATH" ]]; then
  echo "错误: vault 根目录不存在: ${VAULT_PATH:-（未配置）}" >&2
  echo "请设置 VAULT_PATH 环境变量指向你的 Obsidian 库，或将技能包放入库内（零配置），或运行 scripts/init.sh。" >&2
  exit 3
fi

PROJECT_DIR="${PROJECTS_DIR}/${PROJECT}"
mkdir -p "$PROJECT_DIR"

# slug：标题去非法字符，保留中文，截断 20 字符
slug() {
  local s="$1"
  s="${s//\//_}"
  s="${s//\\/_}"
  s="${s//:/_}"
  s="${s//\*/_}"
  s="${s//\?/_}"
  s="${s//\"/_}"
  s="${s//</_}"
  s="${s//>/_}"
  s="${s//|/_}"
  s="${s//[[:space:]]/-}"
  s="${s//--/-}"
  s="${s:0:20}"
  s="${s#-}"
  echo "${s:-untitled}"
}

BASE_NAME="${DATE_STAMP}-${TIME_STAMP}-$(slug "$TITLE")"
FILE_PATH="${PROJECT_DIR}/${BASE_NAME}.md"

# 冲突处理：追加序号
N=2
if [[ -e "$FILE_PATH" ]]; then
  FILE_PATH="${PROJECT_DIR}/${BASE_NAME}-2.md"
  while [[ -e "$FILE_PATH" ]]; do
    N=$((N+1))
    FILE_PATH="${PROJECT_DIR}/${BASE_NAME}-${N}.md"
  done
fi

# 组装 frontmatter + 正文
{
  echo "---"
  echo "type: conversation-digest"
  echo "project: ${PROJECT}"
  echo "source: ${SOURCE:-session-unknown}"
  echo "date: ${DATE_STAMP}"
  echo "status: reviewed"
  echo "tags:"
  IFS=',' read -ra TAG_ARR <<< "$TAGS"
  for t in "${TAG_ARR[@]}"; do echo "  - ${t}"; done
  echo "---"
  echo ""
  echo "# ${TITLE}"
  echo ""
  echo "> 会话沉淀 | ${DATE_STAMP} ${TIME_STAMP} | 项目：${PROJECT}"
  echo ""
  cat "$BODY"
} > "$FILE_PATH"

echo "已写入: ${FILE_PATH}"
