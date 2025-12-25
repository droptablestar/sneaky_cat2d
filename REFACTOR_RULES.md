* Single tick owner per entity: only one script on the enemy runs _physics_process.
* No scene-tree spelunking in components: components get references injected by controller or exported NodePath.
* Controller connects signals; components do not self-connect.
* All .gd filenames must be snake_case.
* class_name (if present) must be PascalCase and match the concept, not the filename.

Every PR must include:
 * what changed
 * how to test (exact steps)
 * expected debug output / behavior
