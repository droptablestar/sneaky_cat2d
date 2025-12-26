# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**SneakyCat2D** is a 3D 2.5D side-scrolling stealth game built with Godot 4.5. The player controls a cat that must avoid detection by enemies (dogs/humans) while navigating through levels. Movement is primarily constrained to the X axis with Y for jumping and Z fixed, creating a side-scroller experience in a 3D environment.

## Essential Commands

### Development
```bash
# Run tests (uses GUT test framework)
./run_tests.sh

# Run tests with custom Godot binary
GODOT_BIN=/path/to/godot ./run_tests.sh

# Install development dependencies (pre-commit hooks, gdtoolkit)
uv sync --group dev

# Run pre-commit hooks manually
pre-commit run --all-files

# Format GDScript files (gdformat)
gdformat scripts/

# Lint GDScript files (gdlint)
gdlint scripts/
```

### Testing
- **Full test suite**: `./run_tests.sh`
- Tests are located in `tests/` directory with subdirectories:
  - `tests/unit/` - Unit tests for individual scripts
  - `tests/smoke/` - Smoke tests for basic functionality
  - `tests/support/` - Test utilities and harness
- Tests use the GUT (Godot Unit Test) framework from `addons/gut/`
- All test files extend `TestHarness` which provides utilities like `instance_player()`, `instance_enemy()`, `step_physics()`, etc.

## Code Architecture

### Core Game Systems

**Hiding System (Authoritative)**
- Binary system: player is either Hidden or Visible
- `HideSpot` nodes (Area3D) define where players can hide
- When player enters a HideSpot area, they can press `hide_toggle` (F key) to hide
- Hidden players are completely invisible to enemy detection
- `scripts/hide_spot.gd` manages HideSpot areas and communicates with player via `register_hide_spot()` and `unregister_hide_spot()`

**Player Controller** (`src/player/player_controller.gd`)
- Extends CharacterBody3D
- Manages player movement (left/right on X axis, jumping on Y axis)
- Handles hide state (`is_hidden` flag)
- Movement is disabled while hidden
- Uses `constrain_z` to enforce 2.5D plane constraint
- Key properties: `move_speed`, `jump_velocity`, `plane_z`

**Enemy AI** (`scripts/enemy_patroller.gd`)
- State machine with three states: PATROL, ALERT, INVESTIGATE
- **PATROL**: Enemy moves between two waypoints
- **ALERT**: Enemy sees player and tracking begins (detection meter fills)
- **INVESTIGATE**: Enemy lost sight, moves to last known position
- Vision-based detection using cone-based field of view
- Detection meter fills gradually when player is visible in ALERT state
- Game restarts when detection meter reaches 100
- Ignores hidden players completely
- Key properties: `patrol_speed`, `detection_distance`, `cone_half_angle_deg`, `detection_fill_rate`

**Visual Components**
- `src/player/player_visuals.gd` and `scripts/enemy_visuals.gd` handle visual representation
- Separation of controller logic from visual presentation
- Uses signals to communicate state changes between controller and visuals

### Node Structure

Main scene (`main.tscn`) hierarchy:
```
Root (Node3D)
├── Player (CharacterBody3D) - src/player/player.tscn
├── FollowCamera (Camera3D) - src/shared/follow_camera.gd
├── Level (Node3D)
│   ├── Floor (StaticBody3D)
│   ├── Furniture (StaticBody3D)
│   │   └── HideSpot (Area3D)
│   ├── Waypoints (Node3D)
│   │   ├── WaypointA, WaypointB
│   └── Enemy (Node3D) - scenes/enemy_patroller.tscn
└── HUD - src/ui/hud.tscn
```

### Directory Structure

- `src/` - Canonical home for gameplay code plus feature scenes (e.g., shared utilities)
- `scripts/` - Legacy gameplay scripts pending migration
- `scenes/` - Godot scene files (.tscn)
- `tests/` - GUT test framework tests
- `addons/` - Third-party addons (GUT)
- `ui/` - UI scenes and scripts
- `assets/` - Models, textures, sounds

## Development Conventions

### GDScript Style
- Uses tabs for indentation (configured in pyproject.toml)
- Line length: 100 characters
- Pre-commit hooks enforce formatting via gdformat and gdlint
- Class names are disabled in gdlint configuration
- Type hints are used throughout (`: float`, `: bool`, etc.)

### Design Principles (from AGENTS.md)
- **Small, focused scripts**: One responsibility per script
- **Explicit state machines**: Prefer clear states over boolean flags
- **Signals for communication**: Use Godot signals for cross-node messaging
- **Clarity over cleverness**: Prioritize readable, debuggable code
- **No premature optimization**: Keep it simple first
- **Player readability**: AI and mechanics should be clear to the player

### Input Actions (project.godot)
- `ui_left`, `ui_right` - Player horizontal movement
- `ui_accept` - Player jump (space bar)
- `hide_toggle` - Toggle hiding (F key, physical keycode 70)

## Testing Utilities (TestHarness)

The `tests/support/test_harness.gd` base class provides:
- `instance_player(add_to_tree: bool)` - Instantiate player for testing
- `instance_enemy(add_to_tree: bool)` - Instantiate enemy for testing
- `add_flat_floor(y: float, size: Vector3)` - Create test collision floor
- `step_physics(target: Node, steps: int, delta: float)` - Manually advance physics
- `press_action(action_name: String, strength: float)` - Simulate input
- `release_action(action_name: String)` - Release simulated input
- `attach_node(node: Node)` - Add node to test scene tree

Test lifecycle:
- `before_each()` - Clears instance tracking and input state
- `after_each()` - Automatically cleans up all instantiated/attached nodes

## CI/CD

GitHub Actions workflow (`.github/workflows/tests.yml`):
- Runs on push/PR to main branch
- Uses Godot 4.5.1 via chickensoft-games/setup-godot action
- Executes `./run_tests.sh`
- Timeout: 15 minutes

## Key Design Rules

1. **Do not introduce new gameplay systems** without explicit instruction
2. **Do not refactor existing systems** unless specifically asked
3. **Hiding is authoritative**: HideSpot state determines visibility, not occlusion/raycasts
4. **Detection is gradual**: No instant fails, detection meter fills over time
5. **2.5D constraint**: Gameplay constrained to X axis movement, Y for jumping, Z is fixed
6. **State clarity**: Use explicit state machines (see enemy_patroller.gd STATE_* constants)

## MVP Status (from GAMEPLAN.md)

Completed:
- ✅ 3D 2.5D side-scroller movement
- ✅ Binary hiding behind furniture
- ✅ Enemy patrol with vision-based detection
- ✅ Detection meter (gradual fill)

Not yet implemented:
- Goal trigger at end of level
- Combat, inventory, power-ups
- Multiple playable characters
- Advanced animations
