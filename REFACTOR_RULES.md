## Project structure (canonical)
- addons/ — Godot plugins only.
- assets/ — art, audio, fonts, and other content; no scripts.
- src/ — all gameplay code plus colocated feature scenes.
  - src/enemy/ — enemy scenes and scripts.
  - src/player/ — player scenes and scripts.
  - src/ui/ — UI scenes and scripts.
  - src/shared/ — shared utilities/components; no scene-tree spelunking.
  - src/gameplay/ — gameplay interactables/systems that aren't enemy/player.
- levels/ — authoritative home for authored levels; do not use src/levels/.
- tests/ — GUT tests.
- docs/ — design and refactor documentation.

### Rules
- Scenes and their scripts must be colocated inside the same feature folder under src/.
- Do not add new scenes or scripts beneath legacy scenes/, scripts/, or ui/.
- All .gd filenames must be snake_case; `class_name` (if used) must be PascalCase and describe the concept, not the filename.
- Single tick owner per entity: only one script implements `_process`/`_physics_process`.
- Controllers own signals and inject dependencies; components never self-connect or crawl the scene tree.
- Visual nodes remain passive and expose `tick()` hooks instead of running their own logic.

### Migration policy
- All new work lands in src/ immediately.
- Moves are mechanical/no-behavior-change unless explicitly stated otherwise.
- After every move fix resource paths, run tests, and ensure gdlint plus pre-commit succeed.

Every PR must include:
 * what changed
 * how to test (exact steps)
 * expected debug output / behavior
