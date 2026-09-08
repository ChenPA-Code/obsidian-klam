#!/usr/bin/env bash
# init.sh — 交互式配置 vault 路径（一次性）。
# 生成 ~/.config/obsidian-knowledge.conf，之后 write_note.sh / check_duplicate.sh 自动读取。
#
# 用法:
#   ./scripts/init.sh            # 交互输入 vault 路径
#   ./scripts/init.sh /路径/vault   # 或直接传参
#
# 如果技能包放在 vault 内部，无需运行本脚本（config.sh 自动探测）。

set -euo pipefail
CONF_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/obsidian-knowledge.conf"

VAULT_INPUT="${1:-}"
if [[ -z "$VAULT_INPUT" ]]; then
  read -r -p "请输入你的 Obsidian vault 根路径（含 .obsidian 的目录）: " VAULT_INPUT
fi

if [[ -z "$VAULT_INPUT" ]]; then
  echo "已取消，未修改配置。" >&2
  exit 1
fi

if [[ ! -d "$VAULT_INPUT" ]]; then
  echo "错误: 目录不存在: $VAULT_INPUT" >&2
  exit 2
fi

mkdir -p "$(dirname "$CONF_FILE")"
printf 'VAULT_PATH="%s"\n' "$VAULT_INPUT" > "$CONF_FILE"
echo "已保存 vault 路径到: $CONF_FILE"

if [[ ! -d "$VAULT_INPUT/.obsidian" ]]; then
  echo "提示: 该目录下未发现 .obsidian 文件夹，请确认它确实是 Obsidian 库根目录。" >&2
  exit 3
fi
echo "校验通过（检测到 .obsidian），配置完成。"
