* Single tick owner per entity: only one script on the enemy runs _physics_process.
* No scene-tree spelunking in components: components get references injected by controller or exported NodePath.
* Controller connects signals; components do not self-connect.

Every PR must include:
 * what changed
 * how to test (exact steps)
 * expected debug output / behavior
