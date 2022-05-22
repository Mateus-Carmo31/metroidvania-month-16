extends Node2D

const PLAYER_SCENE = preload("res://Player.tscn")
const LEVELS = {
	"test_room1": preload("res://RoomTest1.tscn"),
	"test_room2": preload("res://RoomTest2.tscn"),
	"test_area1": preload("res://TestArea.tscn")
}

export var current_room = "test_room1"
var room_node : Node2D = null
var player_node : Node2D = null

func _ready():
	change_room(current_room, 0)

func change_room(new_room_id : String, new_door_id : int):
	if not LEVELS.has(new_room_id):
		push_error("Invalid room id!")
		return

	# Deletes room if there's one active
	if room_node:
		room_node.disconnect("room_changed", self, "change_room")
		remove_child(room_node)
		room_node.delete_room()
		room_node = null
		yield(get_tree(), "idle_frame")

	# Creates new room
	room_node = LEVELS[new_room_id].instance()
	room_node.connect("room_changed", self, "change_room")
	add_child(room_node)
	move_child(room_node, 0)
	current_room = new_room_id

	# Creates player if they don't exist yet
	if not player_node:
		player_node = PLAYER_SCENE.instance()
		add_child_below_node(room_node, player_node)
		$Camera.set_target(player_node)

	# Sets player position to the door marked as `new_door_id`
	if room_node.door_by_id.has(new_door_id):
		player_node.position = room_node.door_by_id[new_door_id].position
	else:
		push_error("Invalid door id!")
		player_node.position = room_node.door_by_id.values()[0]
