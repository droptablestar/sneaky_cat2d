# AGENTS.md (Codex)

## Project: SneakyCat2D
A small 2D stealth/platformer prototype in **Godot 4**. Work is primarily done
**via repo edits** (CLI + editor like Emacs), not the Godot GUI.

## Hard rules (must follow)
- **Repo is source of truth.** Do not invent files, nodes, settings, or UI options.
- **No guessing.** If you can’t verify from the repo, ask for the exact file/diff/output.
- **No large refactors unless explicitly requested.**
- **Follow `REFACTOR_RULES.md`** for canonical structure/migration policy.
- **Low token + low change footprint**: smallest correct patch, minimal churn.
- **No background promises**: produce results in the current response.
- If proposing commands, prefer deterministic commands (`rg`, `sed`, `git diff`, etc.).

## Current workflow preference
1. **Plan-only first** (tie plan steps to concrete repo objects/files).
2. Provide a **single cohesive patch** only after the user explicitly asks to apply changes.
3. End with a **post-change verification checklist** (exact commands).

## Dev environment assumptions
- User prefers **CLI-first** and **Emacs** for edits.
- Avoid reliance on Godot Editor UI; prefer `.tscn` and `.gd` edits directly.
- If something requires editor-only actions, say so explicitly and provide the minimum steps.

## Repo conventions / context
- Godot scenes/scripts are under `src/` (typical examples seen):
    - `src/player/Player.tscn`
    - `src/levels/main.tscn`
    - `src/ui/hud.gd`
    - `src/enemy/*`
- There is linting via **pre-commit** and `gdlint` (gdtoolkit). Keep code style compliant.
- Prior issues: “definition out of order” gdlint errors; keep declarations ordered and stable.

## Immediate gameplay direction (last agreed)
- Player movement exists, but visuals feel static.
- Near-term goal: **collisions + furniture**:
    - Add a “furniture” object the player can walk **in front of** and appear hidden under.
    - Furniture should be “slightly back” in scene depth so the player can overlap properly.
- Avoid “multiple rooms” for now.

## What to do when debugging
- Ask for: `rg` results, relevant `.tscn` nodes, and `git diff`.
- Prefer fixes that:
    - Clarify scene tree wiring and exported NodePaths.
    - Reduce N+1 style node lookups in `_process/_physics_process`.
    - Keep physics ownership clear (one node applies motion).

## Standard command set to request/run (examples)
- Search: `rg -n "pattern" src/`
- Scene/script inspection: `sed -n '1,200p' path/to/file`
- Validate: `pre-commit run -a`
- Minimal diff review: `git diff --stat` then `git diff`

## Output formatting requirements
- When you provide “restart context” prompts or copy/paste blobs, output in a format
  that is easy to paste into Emacs (plain text / fenced code blocks).
- Keep responses terse and technical by default.

## If blocked
If you can’t proceed without more context, ask 1–3 targeted questions and specify the
exact file/command output needed (e.g., “paste `src/levels/main.tscn` node tree”).

# Verification
After making changes run the following commands to verify:
- `gdlint src/`
- `pre-commit run -a`
- `godot --headless --quit`
