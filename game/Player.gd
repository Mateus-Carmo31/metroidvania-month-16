extends KinematicBody2D

class_name Player

export var ground_accel			: float = 800
export var ground_speed			: float = 200
export var air_accel			: float = 200
export var air_speed			: float = 200
export var slowdown_factor		: float = 2
export var gravity				: float = 500
export var jump_accel			: float = 300
export var jump_hold_factor		: float = 0.5
export var coyote_time_window	: int	= 5
export var jump_buffer_window	: int	= 4

var velocity : Vector2
var is_jumping : bool = false
var jump_key_held : bool = false
var coyote_timer : float = 0
var jump_buffer_timer : float = 0

enum {FACING_LEFT, FACING_RIGHT}
var facing = FACING_RIGHT

var touched_floor = false

# TODO: add player element state!
# TODO: add firing
# TODO: find some way to reduce slide

func _ready():
	pass

func _physics_process(delta):

	var input := Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		input += Vector2.LEFT
		facing = FACING_LEFT
	if Input.is_action_pressed("move_right"):
		input += Vector2.RIGHT
		facing = FACING_RIGHT

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_window
		jump_key_held = true

	if Input.is_action_just_released("jump"):
		jump_key_held = false

	# Speed damping
	if is_on_floor():
		if input.x != 0:
			velocity -= velocity * (ground_accel / ground_speed) * delta
		else:
			# Faster slowdown when player stops moving
			velocity -= velocity * (ground_accel / ground_speed) * slowdown_factor * delta
	else:
		# Doesn't damp speed while in air; instead, just clamp it to the max speed. Allows for very predictable jumps
		velocity.x = clamp(velocity.x, -air_speed, air_speed)

	_process_input(input, is_on_floor(), delta)

	# print(velocity.length())
	velocity = move_and_slide_with_snap(velocity, -get_floor_normal() * 10 if not is_jumping else Vector2.ZERO, Vector2.UP, true)

	if not is_on_floor():
		if touched_floor:
			touched_floor = false

		# Variable jump height by changing the gravity
		if not jump_key_held or velocity.y > 0:
			velocity.y += gravity * delta
		else:
			velocity.y += gravity * jump_hold_factor * delta
	else:
		if not touched_floor:
			touched_floor = true

		is_jumping = false
		coyote_timer = coyote_time_window


	coyote_timer = max(coyote_timer - 1, 0)
	jump_buffer_timer = max(jump_buffer_timer - 1, 0)
	# print("Coyote window: ", coyote_timer, " Jump Buffer window: ", jump_buffer_timer)


func _process_input(input : Vector2, grounded : bool, delta : float):

	var dir = input.normalized()

	if grounded:
		dir = dir.rotated(get_floor_angle())

	if input.length() > 0.1:
		if grounded:
			velocity += ground_accel * delta * dir
		else:
			velocity += air_accel * delta * dir

	if not is_jumping and jump_buffer_timer > 0 and (grounded or coyote_timer > 0):
		velocity.y = -jump_accel
		is_jumping = true
