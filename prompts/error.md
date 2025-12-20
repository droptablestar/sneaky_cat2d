Fix-only request.

Godot reports parser errors / warnings treated as errors. Do NOT add features or refactor.
Goal: project loads and runs with zero parser errors and zero warnings that are treated as errors.

Current error (must be fixed):
Parser Error: The variable type is being inferred from a Variant value, so it will be typed as Variant. (Warning treated as error.)

Instructions:
1) Identify the exact file(s) and line(s) triggering the error (search for the message context and likely offenders).
2) Fix by making typing explicit everywhere it matters:
   - Do NOT rely on inference from Variant.
   - Add explicit type annotations: `var x: SomeType = ...`
   - For nodes, use `get_node("...") as Node3D` or `@onready var foo: Node3D = $Foo`
   - For null initializers, use typed nullable patterns:
       `var target: Node3D = null` (or appropriate type)
     and ensure later assignments match the type.
   - Avoid initializing with `{}` or `[]` unless typed:
       `var waypoints: Array[Node3D] = []`
       `var seen_thresholds: Dictionary[int, bool] = {}`
3) Keep diffs minimal: only fix typing / syntax issues required to clear the error.

Completion requirements:
- Update the PR/branch with the fixes.
- Include a "Verification Pass" section:
  - List every file changed
  - For each .gd file: "Parsed OK" and confirm no new warnings-as-errors.
- Confirm you did not introduce C-style ternary (? :).
