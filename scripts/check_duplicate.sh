#!/usr/bin/env bash
# check_duplicate.sh — 幂等查重：检测某会话是否已整理过（按 frontmatter 的 source 字段）。
#
# 用法:
#   check_duplicate.sh --source <会话ID> [--keyword <关键词>]
#
# 行为:
#   - 在 vault 的 Projects 下搜索 source 字段匹配的笔记
#   - 找到: 打印匹配文件路径, 退出码 0
#   - 未找到: 无输出, 退出码 1
#   - 也可用 --keyword 在正文中做主题级查重（可选）

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=config.sh
source "${SCRIPT_DIR}/config.sh"

SOURCE=""
KEYWORD=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)  SOURCE="$2";  shift 2 ;;
    --keyword) KEYWORD="$2"; shift 2 ;;
    *) echo "未知参数: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$SOURCE" && -z "$KEYWORD" ]]; then
  echo "错误: 需要 --source 或 --keyword" >&2
  exit 2
fi

if [[ ! -d "$VAULT_PATH" ]]; then
  echo "错误: vault 根目录不存在: ${VAULT_PATH:-（未配置）}" >&2
  exit 3
fi

MATCHES=""
if [[ -n "$SOURCE" ]]; then
  MATCHES="$(grep -rl "source: ${SOURCE}" "${VAULT_PATH}/Projects" 2>/dev/null || true)"
fi
if [[ -n "$KEYWORD" && -z "$MATCHES" ]]; then
  MATCHES="$(grep -rli "$KEYWORD" "${VAULT_PATH}/Projects" 2>/dev/null || true)"
fi

if [[ -n "$MATCHES" ]]; then
  echo "$MATCHES"
  exit 0
fi
exit 1
