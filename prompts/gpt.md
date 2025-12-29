12/29 - working on setting up level

We are continuing the SneakyCat2D project in the same repo.

CONSTRAINTS / RULES
- Treat me as a senior software engineer with zero Godot experience.
- Godot 4.x only.
- Prefer file-only changes; avoid the editor unless explicitly approved.
- When touching a file, always show the full file contents.
- .tscn files use ';' for comments, not '#'.
- Keep steps small, deterministic, and incremental.
- Do not guess. If unsure, ask targeted questions.
- Minimize token usage; no unnecessary rewrites.

CURRENT STATE
- Project runs.
- Player (CharacterBody2D) can move left/right and jump using arrow keys.
- Single-room interior scene with floor collision.
- Camera is static (no follow needed right now).
- We are not focusing on visuals beyond what’s needed for gameplay clarity.

IMMEDIATE GOAL
- Add collision-based gameplay elements.
- Add a piece of furniture the player can walk under and appear visually hidden beneath.
  - Furniture uses collision: legs block, middle passable.
  - Visual layering occludes the player when underneath.

START
Briefly summarize the known state, then propose one next step only.
