extends Camera2D

export var follow_target = true
export var follow_speed = 20
export var look_ahead_h = 20
export var look_ahead_v = 20
export var look_ahead_accel = 2.5
export var look_ahead_speed = 2.5
export var bounds = Vector2(0,0) # Maximum height

enum {FOLLOW_MODE, STATIC_MODE}

var mode = FOLLOW_MODE
var target
var lookahead_offset = Vector2(0,0)
var current_lookahead_speed = Vector2(0,0)

func _ready():

	if follow_target:
		mode = FOLLOW_MODE
	else:
		mode = STATIC_MODE

	if not target:
		mode = STATIC_MODE
		print("NO TARGET SET!")

func _physics_process(delta):

	if mode == FOLLOW_MODE and target:

		# Takes out offset to update position itself
		position -= lookahead_offset

		# Gets whether player should look left or right
		var lookahead_pos_h = look_ahead_h * (-1 if target.facing == Player.FACING_LEFT else 1)
		var lookahead_pos_v = look_ahead_v * target.look_dir

		# Checks to see how far away from the max offset the camera is (using inverse_lerp)
		var max_speed_h = look_ahead_speed * clamp(1 - inverse_lerp(lookahead_pos_h * 0.8, lookahead_pos_h, lookahead_offset.x), 0, 1)
		var max_speed_v = look_ahead_speed * clamp(1 - inverse_lerp(lookahead_pos_v * 0.8, lookahead_pos_v, lookahead_offset.y), 0, 1)

		current_lookahead_speed.x = clamp(current_lookahead_speed.x + delta * look_ahead_accel * sign(lookahead_pos_h), -max_speed_h, max_speed_h)
		current_lookahead_speed.y = clamp(current_lookahead_speed.y + delta * look_ahead_accel * sign(lookahead_pos_v), -max_speed_v, max_speed_v)

		if lookahead_offset.x == lookahead_pos_h:
			current_lookahead_speed.x = 0

		if lookahead_offset.y == lookahead_pos_v:
			current_lookahead_speed.y = 0

		# Clamps the offset within permissible bounds (there will be another check for level bounds)
		lookahead_offset.x = clamp(lookahead_offset.x + current_lookahead_speed.x, -look_ahead_h, look_ahead_h)
		lookahead_offset.y = clamp(lookahead_offset.y + current_lookahead_speed.y, -look_ahead_v, look_ahead_v)

		# Calculates position and adds the offset
		position = lerp(position, target.position, delta * follow_speed)
		position += lookahead_offset

	else:
		pass

func set_target(node, follow = true):
	target = node
	if follow:
		mode = FOLLOW_MODE
	else:
		mode = STATIC_MODE
