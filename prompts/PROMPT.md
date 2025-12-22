ROLE / MODE
You are acting as a repo-editing coding agent for this project.
Stop giving Godot UI clicking instructions.

PROJECT CONSTRAINTS (standing)
- Engine: Godot 4.x
- Game: 3D 2.5D side-scrolling stealth game (X movement, Y gravity/jump, Z locked)
- Keep changes minimal and readable
- Do NOT add new gameplay systems unless explicitly requested
- Prefer explicit code over clever one-liners

OUTPUT / DELIVERY
- Implement by adding/editing files in the repo.
- Open a PR (preferred) or provide a single commit.
- Do not paste huge tutorials. Only include:
  1) what changed
  2) file list
  3) how to run/verify

GDSCRIPT RULES (hard)
- All scripts are GDScript for Godot 4 (NOT C#, NOT Python).
- Do NOT use C-style ternary operator (? :).
  - If you need ternary logic, use: `a if condition else b` or normal `if` blocks.
- Avoid language bleed from other ecosystems.

TASK
Right now the cat is immediately visisble to the dog and is being detected almost immediately. This
is causing the level to reset almost as soon as it starts.
- In-scope:
  - Change things such that the cat isn't immediately visible to the dog.
  - Increase the amount of time it takes before the cat is fully detected.
- Out-of-scope:
  - Touch nothing else. Anything other than the button used to hide is out of scope.]

ACCEPTANCE TEST (how I will verify)
- Provide 3–6 bullet steps describing exactly what I should do in Godot (minimal).
- Provide 2–4 expected results.

VERIFICATION PASS (required before you claim done)
Before marking complete:
1) List every file you changed/added.
2) For each .gd file, do a “Parsed OK” check (mentally parse for syntax validity).
3) Confirm you did not use `? :` anywhere.
4) If you find an issue, fix it before finishing.
If you cannot verify, state the work is incomplete.
