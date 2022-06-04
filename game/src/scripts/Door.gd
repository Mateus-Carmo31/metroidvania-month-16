extends Area2D

class_name Door

export(int) var door_id
export(String) var destination_room_id = ""
export(int) var destination_door_id = 0
signal entered_door

func interact():
	emit_signal("entered_door")
