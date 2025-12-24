# AGENTS.md

## Quick context
- Engine: Godot 4.x
- Game: 3D / 2.5D side-scrolling stealth (cat avoids detection)
- Constraint: gameplay on X (movement) + Y (jump); Z fixed

## Source-of-truth wiring (don’t reinvent)
- Main scene: `main.tscn` instantiates `Player`, `Enemy`, `HUD`, and level geometry (with HideSpots).
- HUD discovery uses groups:
    - `"player"` (Player)
    - `"enemy"` (Enemy)
- Signals used for UI:
    - Player emits `hidden_state_changed(is_hidden)`
    - Enemy emits `detection_meter_changed(value)`
- Hiding authority:
    - `HideSpot (Area3D)` only registers/unregisters availability with the Player.
    - Player owns `is_hidden`; enemies must gate detection on `!player.is_hidden`.

## Gameplay rules (stable)
- Player movement is constrained to a 2.5D plane (no free 3D roaming).
- Enemies detect via vision cone / LOS checks.
- Detection fills over time; avoid instant detection.
- When detection meter is full: player is caught and level restarts.

## Enemy AI guidelines
- Enemies use a simple, readable state machine:
    - Patrol
    - Investigate (optional)
    - Chase (later expansion)
- Prioritize clarity and player readability over realism.
- Vision cones should be visible in debug mode.

## Working style (token-efficient)
- Touch the minimum number of files needed.
- Before coding, always state:
    1. Files to touch
    2. Behavior change
    3. Any new or changed signals, groups, or InputMap actions
- Do not introduce new gameplay systems or refactor unrelated code unless explicitly requested.
- When asked to change a file, provide the **full replacement file contents** (not a patch or diff).

## Code conventions
- Prefer typed GDScript where it improves readability.
- Keep scripts focused (one responsibility per script).
- Prefer explicit state machines over boolean flag soup.
- Prefer signals over polling for cross-node communication.
- Gameplay constants belong in `scripts/game_constants.gd` (or the existing constants module).

## File structure
- `scenes/` — Godot scenes
- `scripts/` — GDScript files
- `ui/` — UI scenes and scripts
- `assets/` — Models, textures, sounds
