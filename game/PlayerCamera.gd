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
var current_facing = Player.FACING_RIGHT
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

		if current_facing != target.facing:
			current_facing = target.facing

		# Gets whether player should look left or right
		var lookahead_pos = look_ahead_h * (-1 if current_facing == Player.FACING_LEFT else 1)

		# Checks to see how far away from the max offset the camera is (using inverse_lerp)
		var max_speed = look_ahead_speed * clamp(1 - inverse_lerp(lookahead_pos * 0.8, lookahead_pos, lookahead_offset.x), 0, 1)

		current_lookahead_speed.x = clamp(current_lookahead_speed.x + delta * look_ahead_accel * sign(lookahead_pos), -max_speed, max_speed)

		if lookahead_offset.x == lookahead_pos:
			current_lookahead_speed.x = 0

		# Clamps the offset within permissible bounds (there will be another check for level bounds)
		lookahead_offset.x = clamp(lookahead_offset.x + current_lookahead_speed.x, -look_ahead_h, look_ahead_h)

		# Calculates position and adds the offset
		position = lerp(position, target.position, delta * follow_speed)
		position += lookahead_offset

		# TODO: make max offset somewhere here!

	else:
		pass

func set_target(node, follow = true):
	target = node
	if follow:
		mode = FOLLOW_MODE
