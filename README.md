# SneakyCat2D

A 3D 2.5D side-scrolling stealth game built with Godot 4.5. Play as a cat that must avoid detection by enemies while navigating through levels.

## Overview

SneakyCat2D is a stealth-based game where the player controls a cat trying to sneak past enemies (dogs and humans). The game features a 2.5D perspective - movement is primarily along the X axis with jumping on the Y axis, while the Z position remains fixed, creating a side-scroller experience in a 3D environment.

### Core Mechanics

- **2.5D Movement**: Side-scrolling gameplay constrained to a plane (X for horizontal movement, Y for jumping, Z fixed)
- **Hiding System**: Binary hide/visible state - player can hide behind furniture to avoid detection
- **Enemy Detection**: Gradual detection meter that fills when enemies see the player
- **Stealth Gameplay**: Avoid being caught by staying out of enemy vision cones or hiding

## Getting Started

### Prerequisites

- [Godot 4.5.1](https://godotengine.org/) or later
- Python 3.10+ (for development tools)
- [uv](https://github.com/astral-sh/uv) package manager (optional, for pre-commit hooks)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd sneaky_cat2d
   ```

2. Open the project in Godot:
   ```bash
   godot --editor project.godot
   ```

3. (Optional) Install development dependencies:
   ```bash
   uv sync --group dev
   pre-commit install
   ```

### Running the Game

**From Godot Editor:**
- Press F5 or click the "Play" button in the top-right corner

**From Command Line:**
```bash
godot --path . res://main.tscn
```

## Development

### Project Structure

```
sneaky_cat2d/
├── scripts/          # All GDScript source files
│   ├── game_constants.gd           # Centralized game constants
│   ├── base_character_visuals.gd   # Base class for character animations
│   ├── position_utils.gd           # Position utility functions
│   ├── player_controller.gd        # Player movement and state
│   ├── player_visuals.gd           # Player animation logic
│   ├── enemy_patroller.gd          # Enemy AI (patrol/alert/investigate)
│   ├── enemy_visuals.gd            # Enemy animation logic
│   ├── hud.gd                      # HUD display logic
│   ├── follow_camera.gd            # Camera following player
│   └── hide_spot.gd                # Hide spot interaction
├── scenes/          # Godot scene files (.tscn)
├── tests/           # GUT test framework tests
│   ├── unit/        # Unit tests
│   ├── smoke/       # Smoke tests
│   └── support/     # Test utilities
├── ui/              # UI scenes and scripts
├── assets/          # Models, textures, sounds
└── addons/          # Third-party addons (GUT)
```

### Running Tests

**Run all tests:**
```bash
./run_tests.sh
```

**With custom Godot binary:**
```bash
GODOT_BIN=/path/to/godot ./run_tests.sh
```

The test suite uses the [GUT (Godot Unit Test)](https://github.com/bitwes/Gut) framework and includes:
- Unit tests for individual components
- Smoke tests for scene integrity
- Test harness with utilities for physics simulation and input mocking

### Code Style

This project uses:
- **gdformat** for code formatting (100 character line length, tabs)
- **gdlint** for linting (with `class-name` check disabled)
- **pre-commit** hooks for automatic formatting on commit

**Format code:**
```bash
gdformat scripts/
```

**Lint code:**
```bash
gdlint scripts/
```

**Run pre-commit manually:**
```bash
pre-commit run --all-files
```

### Input Controls

- **Arrow Keys / A/D**: Move left/right
- **Space**: Jump
- **F**: Toggle hiding (when near a hide spot)

## Game Architecture

### Hiding System

The hiding system is **authoritative** - the player is either fully hidden or visible:
- `HideSpot` nodes (Area3D) define where players can hide
- When hidden, the player is completely invisible to enemy detection
- Hiding freezes player velocity to prevent movement while hidden

### Enemy AI

Enemies use a state machine with three states:

1. **PATROL**: Move between waypoints
2. **ALERT**: Player spotted, detection meter fills
3. **INVESTIGATE**: Player lost, move to last known position

Detection features:
- Vision cone-based detection
- Gradual detection meter (fills over time when seen)
- Grace period before detection starts filling
- Game restarts when detection meter reaches 100%

### Visual System

Character visuals use a base class pattern:
- `BaseCharacterVisuals` provides common animation state management
- Subclasses (`PlayerVisuals`, `EnemyVisuals`) implement specific animation logic
- Supports sprite flipping based on movement direction

### Signals & Communication

The game uses signals for loose coupling:
- `player.hidden_state_changed(is_hidden: bool)` - Player hide state changes
- `enemy.detection_meter_changed(value: float)` - Detection meter updates

The HUD listens to these signals instead of polling, improving performance.

## Technical Details

### Game Constants

All magic numbers are centralized in `GameConstants`:
- Physics thresholds (position snapping, velocity flipping)
- Detection meter values (max, bucket size)
- Animation names (idle, walk, hidden, jump)

### Position Management

Position clamping utilities in `PositionUtils`:
- `clamp_to_plane()` - Constrains Vector3 to specific Y/Z planes
- `apply_plane_clamping()` - Applies clamping to a Node3D

### Testing Utilities

`TestHarness` base class provides:
- `instance_player()` / `instance_enemy()` - Scene instantiation
- `step_physics()` - Manual physics simulation
- `press_action()` / `release_action()` - Input mocking
- `add_flat_floor()` - Test collision setup
- Automatic cleanup of instantiated nodes

## Current Status

### Implemented Features ✅

- 3D 2.5D side-scroller movement
- Binary hiding behind furniture
- Enemy patrol with vision-based detection
- Gradual detection meter
- Player and enemy animations
- HUD display
- Camera following

### Planned Features

- Goal trigger at end of level
- Multiple levels
- Advanced animations
- Sound effects and music

## Contributing

1. Follow the existing code style (use pre-commit hooks)
2. Write tests for new functionality
3. Update documentation as needed
4. Run tests before committing: `./run_tests.sh`

## License

[Specify license here]

## Credits

Built with [Godot Engine 4.5](https://godotengine.org/)

Testing framework: [GUT](https://github.com/bitwes/Gut)
