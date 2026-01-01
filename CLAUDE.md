# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in
this repository.

## Project Overview

SneakyCat2D is a side-scrolling stealth game built with **Godot 4.5**. The project is in
early development with basic movement implemented but no gameplay mechanics yet.
Development is done **CLI-first** with direct file editing (not via Godot Editor GUI).

### Core Game Design
- **Victory**: reach the level exit
- **Failure**: get caught by an enemy
- **Player actions**: move, hide
- **Enemies**: patrol and detect the player via vision with gradual detection (meter fills/decays)
- **Cover system**: enemies can lose sight if player hides behind depth-based cover

## Development Commands

### Running the Game
```bash
# Run the game
godot --path .

# Run headless (validation only)
godot --headless --quit
```

### Linting and Pre-commit
```bash
# Lint all GDScript files
gdlint src/

# Run all pre-commit hooks
pre-commit run -a
```

### Python Environment
```bash
# Install dev dependencies (gdtoolkit, pre-commit)
uv sync --group dev
```

### Search and Inspection
```bash
# Search for patterns in source
rg -n "pattern" src/

# Inspect specific file lines
sed -n '1,200p' path/to/file
```

## Critical Development Rules

1. **Repository is source of truth**: Do not invent files, nodes, settings, or UI options.
Always verify from actual repo files.

2. **No guessing**: If you can't verify something from the repo, ask for the exact
file/diff/output.

3. **CLI-first workflow**: Prefer editing `.tscn` and `.gd` files directly. Avoid reliance
on Godot Editor UI. If something requires editor-only actions, say so explicitly and provide
minimum steps.

4. **Minimal changes**: Low token + low change footprint. Smallest correct patch, minimal churn.

5. **Verification after changes**: Always run these commands after making changes:
   ```bash
   gdlint src/
   pre-commit run -a
   godot --path .  # Validate no parse errors
   ```

6. **GDScript linting**: Watch for "definition out of order" gdlint errors. Keep declarations
ordered and stable.

7. **Godot resource files (.tres)**: Must have proper structure:
   - `[gd_resource]` header first
   - `[ext_resource]` declarations for external references
   - `[sub_resource]` declarations for internal sub-resources
   - `[resource]` section with main resource properties

## Architecture

### Project Structure
```
src/
├── player/
│   ├── Player.tscn       # Player character scene
│   └── player.gd         # CharacterBody2D with platformer movement
├── levels/
│   ├── main.tscn         # Main scene (entry point)
│   ├── main.gd           # Camera reparenting logic
│   ├── RoomVisuals.tscn  # Reusable room visual component
│   ├── room_visuals.gd   # Configurable room colors/wallpaper
│   ├── camera_follow.gd  # X-axis camera follow with fixed Y
│   └── *.tres            # Shader materials and textures
└── enemy/                # (Not yet implemented)
```

### Key Architectural Patterns

**Scene Composition**: The main scene (`src/levels/main.tscn`) instances reusable room visuals
and manages the camera system. Each room is an instance of `RoomVisuals.tscn` with configurable
colors and positions.

**Camera System**: Camera follows player on X-axis while keeping Y fixed at 360 (floor framing
stability). The camera uses `camera_follow.gd` script with exported `target_path` and `fixed_y`
properties.

**Player Movement**: Direct keyboard polling (no InputMap) for deterministic behavior. CharacterBody2D
with gravity, horizontal movement, and jump. Keys: LEFT/A, RIGHT/D for movement; SPACE/ENTER
for jump.

**Room Visuals**: Modular room system with:
- Wall layer (z-index -10)
- Wallpaper layer (z-index -9) with shader material for dot pattern
- Floor visual layer (z-index -6)
- Configurable via exported Color properties

**Physics**: Separate StaticBody2D for floor collisions. Physics ownership is clear (one node
applies motion via `move_and_slide()`).

### Scene Tree Wiring

The main scene uses `@onready` node references and exported NodePaths for cross-node communication.
Example from `main.gd`:
```gdscript
@onready var cam := $Camera2D
@onready var player := $Player
```

Avoid N+1 style node lookups in `_process/_physics_process`. Cache node references in
`_ready()` or use `@onready`.

## Common Debugging Approach

When debugging, request:
- `rg` search results for relevant patterns
- Relevant `.tscn` node tree structure
- `git diff` to see what changed

Prefer fixes that:
- Clarify scene tree wiring and exported NodePaths
- Reduce repeated node lookups in process loops
- Keep physics ownership clear

## Current Development Focus

Near-term goal is adding **collisions + furniture**:
- Add furniture objects the player can walk in front of and appear hidden under
- Furniture should be "slightly back" in scene depth for proper overlap
- Avoid "multiple rooms" complexity for now

## Output Format

When providing code blocks or restart context, use plain text or fenced code blocks that
are easy to paste into Emacs. Keep responses terse and technical.
