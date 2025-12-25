# Enemy Flow

Docs for the current enemy patroller setup (Godot 4.x). No behavior changes; this is a wiring map.

## Scene
- Scene: `scenes/enemy_patroller.tscn` (instanced from `main.tscn` under `Level/Enemy`).
- Scene tree:
  - `Enemy` (Node3D, script: `scripts/enemy_patroller.gd`)
    - `MeshInstance3D` (CapsuleMesh, hidden helper)
    - `StateLabel` (Label3D) — displays current AI state text
    - `Visuals` (Node3D, script: `scripts/enemy_visuals.gd`)
      - `BillboardSprite` (Sprite3D) — shows the SubViewport output
      - `SpriteViewport` (SubViewport)
        - `DogSprite` (AnimatedSprite2D, frames: `assets/sprites/dog_spriteframes.tres`)
- Exported paths on `Enemy`: `player_path`, `waypoint_a_path`, `waypoint_b_path`.

## Scripts
- `scripts/enemy_controller.gd`
  - Role: Enemy controller and state machine (PATROL, ALERT, INVESTIGATE).
  - Signals: `detection_meter_changed(value: float)`.
  - Groups: adds itself to `"enemy"` in `_ready()`.
  - Handles detection meter fill/decay, state label updates, and reload on catch.
- `scripts/enemy_visuals.gd` (on `Visuals`)
  - Role: Choose animations based on movement/state and handle sprite flipping.
  - Depends on parent (`Enemy`) exposing `get_state` and state constants.
  - Uses `BaseCharacterVisuals` helpers for animation playback/flip.
- `scripts/base_character_visuals.gd` (base class)
  - Role: Common animation runner for characters; provides `tick` to pick animation and flip horizontally.

## Per-frame entrypoints
- `Enemy` (`enemy_patroller.gd`):
  - `_physics_process(delta)`: Runs AI state machine, vision checks, meter fill/decay, emits `detection_meter_changed`, and reloads scene if meter hits max.
- `Visuals` (`enemy_visuals.gd` via `BaseCharacterVisuals`):
  - `_physics_process(delta)`: Chooses target animation, updates AnimatedSprite2D, and flips sprite based on last horizontal motion. Relies on `_determine_target_animation()` override in `enemy_visuals.gd`.
