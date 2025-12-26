# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Operating Mode (hard)
- Minimize tokens. Ask for *file ranges* or specific symbols; don’t request/paste full files.
- One small change per iteration. Apply it, then stop.
- Never invent nodes/APIs. Verify in repo before proposing changes.

## Project Overview

**SneakyCat2D** is a 3D 2.5D side-scrolling stealth game built with Godot 4.5.
Movement is primarily constrained to X (left/right), Y for jumping, Z fixed.

## Hard Refactor Constraints (REFACTOR_RULES.md)
- Canonical dirs:
    - `addons/` plugins only
    - `assets/` content only (no scripts)
    - `src/` **all gameplay code + colocated feature scenes**
    - `levels/` authored levels only (do not use `src/levels/`)
    - `tests/` GUT tests
    - `docs/` design/refactor docs
- **All new work lands in `src/` immediately.**
- Do not add new scenes/scripts under legacy `scripts/`, `scenes/`, or `ui/`.
- Scenes and scripts must be colocated under `src/<feature>/`.
- `.gd` filenames snake_case; `class_name` (if used) PascalCase and concept-based.
- Single tick owner per entity: only one script implements `_process`/`_physics_process`.
- Controllers own signals + inject deps; components never self-connect or crawl the scene tree.
- Visual nodes remain passive and expose `tick()` hooks (no logic loops).

### Migration policy
- Moves are mechanical/no-behavior-change unless explicitly stated.
- After any move: fix resource paths, run tests, ensure `gdlint` + `pre-commit` succeed.

### Every PR must include
- what changed
- how to test (exact steps)
- expected debug output / behavior

## Essential Commands

### Development
```bash
# Run tests (GUT)
./run_tests.sh

# Run tests with custom Godot binary
GODOT_BIN=/path/to/godot ./run_tests.sh

# Install dev deps (pre-commit hooks, gdtoolkit)
uv sync --group dev

# Run pre-commit hooks manually
pre-commit run --all-files

# Format GDScript files (gdformat) - canonical code only
gdformat src/

# Lint GDScript files (gdlint) - canonical code only
gdlint src/
