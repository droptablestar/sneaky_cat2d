#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
GODOT_CMD="${GODOT_CMD:-godot}"
GODOT_TEST_HOME="${GODOT_TEST_HOME:-"$SCRIPT_DIR/.godot_test_home"}"

mkdir -p "$GODOT_TEST_HOME"
export GODOT_USER_HOME="$GODOT_TEST_HOME"
export HOME="$GODOT_TEST_HOME"

exec "$GODOT_CMD" --headless --quit --path "$SCRIPT_DIR" \
  -s addons/gut/gut_cmdln.gd "$@"
