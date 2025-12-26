## Debug utilities
##
## Centralized helper for debug logging to keep output consistent.
class_name DebugUtils


static func dbg(
	message: Variant, arg1: Variant = null, arg2: Variant = null, arg3: Variant = null
) -> void:
	if arg3 != null:
		print(message, arg1, arg2, arg3)
	elif arg2 != null:
		print(message, arg1, arg2)
	elif arg1 != null:
		print(message, arg1)
	else:
		print(message)
