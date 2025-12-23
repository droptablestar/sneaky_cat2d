## Centralized game constants
##
## This class provides a single source of truth for all magic numbers and string
## literals used throughout the game. Centralizing these values makes the codebase
## more maintainable and reduces the risk of typos or inconsistencies.
class_name GameConstants

# Physics thresholds
## Distance threshold for snapping positions (e.g., arrival at waypoints).
## When an entity is within this distance of a target, it's considered "arrived".
const POSITION_SNAP_THRESHOLD: float = 0.05

## Velocity threshold for sprite flipping.
## Sprite flip only occurs if velocity exceeds this value to prevent jittering.
const VELOCITY_FLIP_THRESHOLD: float = 0.01

# Detection meter
## Maximum value of the enemy detection meter.
## When the meter reaches this value, the player is caught.
const DETECTION_METER_MAX: float = 100.0

## Detection meter bucket size for notifications.
## Meter changes are reported in increments of this size (0, 25, 50, 75, 100).
const DETECTION_METER_BUCKET_SIZE: float = 25.0

## Initial bucket value for detection meter tracking.
## Set to -25 to ensure the first detection notification triggers at 0.
const DETECTION_METER_INITIAL_BUCKET: int = -25

# Animation names
## Animation name for idle/stationary state
const ANIM_IDLE: String = "idle"

## Animation name for walking/moving state
const ANIM_WALK: String = "walk"

## Animation name for hidden state (player only)
const ANIM_HIDDEN: String = "hidden"

## Animation name for jumping/airborne state (player only)
const ANIM_JUMP: String = "jump"
