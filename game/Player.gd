extends KinematicBody2D

onready var bullet = preload("res://Bullet.tscn")
class_name Player

export var ground_accel				: float = 800
export var ground_speed				: float = 200
export var air_accel				: float = 500
export var air_speed				: float = 200
export var slowdown_factor			: float = 3
export var gravity					: float = 1500
export var jump_accel				: float = 400
export var jump_hold_factor			: float = 0.4
export var coyote_time_window		: int	= 7
export var jump_buffer_window		: int	= 4
export var wall_grab_max_duration	: float	= 0.2
export var wall_jump_buffer_window	: int	= 3

var input_active := true
var velocity : Vector2

var is_jumping : bool = false
var jump_key_held : bool = false
var coyote_timer : float = 0
var jump_buffer_timer : float = 0

var is_wall_grabbing : bool = false
var last_wall = null
var wall_jump_buffer_timer : float = 0

enum {FACING_LEFT, FACING_RIGHT, FACING_UP, FACING_DOWN}
var facing = FACING_RIGHT

var touched_floor = false

enum Element {None, Fire, Grass, Ice}
var current_element = 0

# TODO: add player element state!
# TODO: increase player size
# TODO: add firing
# TODO: find some way to reduce slide

func _ready():
	$WallGrabTimer.connect("timeout", self, "stop_wallgrab")

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
		wall_jump_buffer_timer = wall_jump_buffer_window
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

	if input_active:
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

		# Reset things that need resetting when touching the ground here!
		if not touched_floor:
			touched_floor = true

		is_jumping = false
		coyote_timer = coyote_time_window
		stop_wallgrab(true)

	coyote_timer = max(coyote_timer - 1, 0)
	jump_buffer_timer = max(jump_buffer_timer - 1, 0)
	wall_jump_buffer_timer = max(wall_jump_buffer_timer - 1, 0)


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
		jump_buffer_timer = 0

	if Input.is_action_just_pressed("interact"):
		check_for_interactables()

	if Input.is_action_just_pressed("element_forward"):
		current_element = (current_element + 1) % len(Element)
		print("Current element: ", Element.keys[current_element])

	do_wall_grab(input, delta)

	#shoot
	if Input.is_action_just_pressed("fire"):
		shoot()

func check_for_interactables():

	var interactables = $Interact.get_overlapping_areas()

	if interactables:
		var closest = interactables[0]
		var dist = (closest.global_position as Vector2).distance_to(global_position)
		for i in interactables:
			var i_dist = (i.global_position as Vector2).distance_to(global_position)
			if i_dist < dist:
				closest = i
				dist = i_dist

		closest.interact()

func do_wall_grab(input, _delta):

	grab_wall(input)

	if is_wall_grabbing:
		velocity.y = 0

		if input.x != 0 and sign(input.x) != sign(last_wall.position.x - position.x):
			stop_wallgrab()
			return

		if wall_jump_buffer_timer > 0:
			if last_wall.position.x - position.x > 0:
				velocity = Vector2(-1, -1).normalized() * 400
			else:
				velocity = Vector2( 1, -1).normalized() * 400

			stop_wallgrab()

func stop_wallgrab(remove_wall = false):
	$WallGrabTimer.stop()
	is_wall_grabbing = false
	if remove_wall:
		last_wall = null

func grab_wall(input):

	var walls

	if input.x > 0:
		walls = $WallCheckR.get_overlapping_bodies()
	elif input.x < 0:
		walls = $WallCheckL.get_overlapping_bodies()

	if walls:
		if walls[0] != last_wall:
			last_wall = walls[0]
			if is_wall_grabbing == false:
				$WallGrabTimer.start(wall_grab_max_duration)
			is_wall_grabbing = true

func shoot():
		var b = bullet.instance()
		get_parent().add_child(b)
		b.global_position = $Position2D.global_position
		if facing == FACING_LEFT:
			b.dir = Vector2(-1,0)
		if Input.is_action_pressed("look_up"):
			b.dir = Vector2(0,-1) 
		if Input.is_action_pressed("look_down") and not is_on_floor():
			b.dir = Vector2(0,1) 
