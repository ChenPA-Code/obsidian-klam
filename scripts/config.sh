#!/usr/bin/env bash
# config.sh — 统一配置。被 write_note.sh / check_duplicate.sh source 引用。
#
# vault 路径解析优先级（从高到低）：
#   1) 环境变量 VAULT_PATH（临时覆盖）
#   2) 自动探测：技能包位于 vault 内部时，向上查找含 .obsidian 的目录 → 零配置
#   3) 用户配置文件 ~/.config/obsidian-knowledge.conf（由 scripts/init.sh 生成）
#   4) 常见位置探测（~/Documents、~/Obsidian、$HOME，maxdepth 3）
#   5) 报错提示（本包不含演示库）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"          # .../obsidian-klam
ROOT_DIR="$(dirname "$SKILL_DIR")"            # 技能包所在根目录

VAULT_PATH="${VAULT_PATH:-}"

# --- 2) 向上探测 .obsidian（技能包放进 vault 内 → 使用者零配置） ---
if [[ -z "$VAULT_PATH" ]]; then
  dir="$SKILL_DIR"
  while [[ "$dir" != "/" && "$dir" != "." ]]; do
    if [[ -d "$dir/.obsidian" ]]; then
      VAULT_PATH="$dir"
      break
    fi
    dir="$(dirname "$dir")"
  done
fi

# --- 3) 用户配置文件（init.sh 生成） ---
CONF_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/obsidian-knowledge.conf"
if [[ -z "$VAULT_PATH" && -f "$CONF_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONF_FILE" 2>/dev/null || true
fi

# --- 4) 常见位置探测 ---
if [[ -z "$VAULT_PATH" ]]; then
  found=""
  for base in "$HOME/Documents" "$HOME/Obsidian" "$HOME"; do
    [[ -d "$base" ]] || continue
    found="$(find "$base" -maxdepth 3 -type d -name .obsidian 2>/dev/null | head -1)"
    [[ -n "$found" ]] && break
  done
  if [[ -n "$found" ]]; then
    VAULT_PATH="$(dirname "$found")"
    echo "[config] 已自动发现 vault: ${VAULT_PATH}" >&2
  fi
fi

# --- 5) 未找到时提示 ---
if [[ -z "$VAULT_PATH" ]]; then
  echo "[config] 未检测到 Obsidian vault。" >&2
  echo "[config] 请将技能包放入库内（零配置），或运行 scripts/init.sh 配置路径，或设置 VAULT_PATH 环境变量。" >&2
  VAULT_PATH=""
fi

# 笔记目录（固定，不建议改）：笔记直接写入 Projects/<项目名>/
PROJECTS_DIR="${VAULT_PATH}/Projects"

# 日期时间戳
DATE_STAMP="$(date +%Y-%m-%d)"
TIME_STAMP="$(date +%H%M)"
