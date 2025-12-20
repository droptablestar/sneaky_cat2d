# AGENTS.md

## Project Overview
- Engine: Godot 4.x
- Game Type: 3D 2.5D side-scrolling stealth game
- Perspective: Side-on camera, gameplay constrained primarily to X axis (Y for jumping, Z fixed)
- Player: A cat avoiding detection from enemies (dogs, humans)
- Project Scope: Solo indie project, AI-assisted development

## Core Gameplay Rules
- Player movement is constrained to a 2.5D plane (no free 3D roaming).
- Stealth is the core mechanic.
- Player can hide behind furniture using defined HideSpot areas.
- Enemies detect the player via vision cones and line-of-sight checks.
- If the player is hidden, enemies cannot detect them.
- Detection fills over time; instant detection is discouraged.
- When detection meter is full, the player is caught and the level restarts.
- Each level has a clear goal endpoint.

## Hiding System (Authoritative)
- Furniture defines HideSpot areas using Area3D nodes.
- Hiding is binary: player is either Hidden or Visible.
- Hidden players are ignored by enemy detection systems.
- Occlusion via raycasts may be added later, but HideSpot state is authoritative.

## Enemy AI Guidelines
- Enemies use simple, readable behavior:
  - Patrol
  - Investigate (optional)
  - Chase (later expansion)
- Enemy AI must prioritize clarity and player readability over realism.
- Vision cones should be visible in debug mode.

## Technical Conventions
- Use Godot 4 built-in nodes (CharacterBody3D, Area3D, etc.).
- Scripts should be small and focused (one responsibility per script).
- Prefer explicit state machines over boolean flag soup.
- Avoid premature optimization.
- Use signals for cross-node communication when appropriate.

## File Structure (Guideline)
- `scenes/` — Godot scenes
- `scripts/` — GDScript files
- `systems/` — Cross-cutting gameplay systems (detection, hiding, state)
- `ui/` — UI scenes and scripts
- `assets/` — Models, textures, sounds

## AI Assistant Instructions
- Do not introduce new gameplay systems without explicit instruction.
- Do not refactor existing systems unless asked.
- Always specify:
  - Node tree structure
  - Script locations
  - Input map actions
- Prefer clarity and debuggability over clever or abstract solutions.
- Ask clarifying questions if a request conflicts with this document.
