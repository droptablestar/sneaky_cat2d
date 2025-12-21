#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
GODOT_CMD="${GODOT_CMD:-godot}"

exec "$GODOT_CMD" --headless --path "$SCRIPT_DIR" -s addons/gut/gut_cmdln.gd "$@"
