extends Node2D

export var room_id : String
var door_by_id : Dictionary

signal room_changed(new_room_id, new_door_id)

func _ready():

	var doors = get_tree().get_nodes_in_group("doors")

	for door in doors:
		door_by_id[door.door_id] = door
		door.connect("entered_door", self, "_change_room", [door.destination_room_id, door.destination_door_id])

func _change_room(room_id, door_id):
	print("Changing to room \"%s\" (door %s)" % [room_id, door_id])
	emit_signal("room_changed", room_id, door_id)


func delete_room():
	queue_free()
