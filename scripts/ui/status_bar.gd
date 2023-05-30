extends TabContainer



func _ready():
#	data.connect("grid_size_changed", _on_grid_size_changed)
	relay.grid_size_changed.connect(_on_grid_size_changed)
	_on_grid_size_changed() # update at start




func _on_grid_size_changed():
	var map := data.get_current_map()
	print("changing grid size:  ", map.grid_size)
	if map.grid_size >= 1:
		%status_grid_size.text = "Grid size: %d" % [map.grid_size]
	elif map.grid_size == 0.5:
		%status_grid_size.text = "Grid size: 0.5"
	elif map.grid_size == 0.25:
		%status_grid_size.text = "Grid size: 0.25"
	elif map.grid_size == 0.125:
		%status_grid_size.text = "Grid size: 0.125"
