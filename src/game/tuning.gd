## Tuning constants for SneakyCat2D.
## Centralized gameplay values to reduce magic numbers.
class_name Tuning

# === Player Physics ===
const MOVE_SPEED_DEFAULT: float = 240.0
const MOVE_SPEED_HIDDEN: float = 100.0
const JUMP_VELOCITY_DEFAULT: float = -420.0
const GRAVITY_DEFAULT: float = 1200.0

# === Player Collision & Layout ===
const PLAYER_COLLIDER_WIDTH: float = 32.0
const PLAYER_COLLIDER_HEIGHT: float = 48.0
# Sprite Y offset from player origin (feet positioning)
const PLAYER_SPRITE_Y_OFFSET: float = 24.0
# Y-sort origin (determines draw order based on vertical position)
const PLAYER_Y_SORT_ORIGIN: float = 24.0

# === Player Hide Behavior ===
# Vertical sprite adjustment when hiding (shifts sprite down visually)
const PLAYER_HIDE_SPRITE_ADJUST: float = -10.0
