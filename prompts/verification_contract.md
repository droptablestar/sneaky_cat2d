Before marking any task as complete, you MUST perform a verification pass.

Verification requirements:
- All GDScript must be valid Godot 4 syntax.
- Do NOT use C-style ternary operators (? :).
- Do NOT assume syntax from other languages.
- For each modified or added .gd file, mentally parse the code and confirm it would load without parser errors.

Completion protocol:
- After generating code, do a "Verification Pass" section:
  - List each file touched
  - State explicitly: "Parsed OK" or "Issue found"
- If any issue is found, fix it before finishing.
- If you cannot verify, state that the task is incomplete.

Do NOT claim the task is finished without a Verification Pass.
Acknowledge these rules before continuing.
