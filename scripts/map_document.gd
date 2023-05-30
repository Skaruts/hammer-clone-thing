class_name MapDocument extends Node3D

var grid_size:float = 64:
	set(gs):
		if gs == grid_size: return
		grid_size = gs
		relay.grid_size_changed.emit()
	get:
		return grid_size


func _init(_name:String):
	name = _name
