extends SubViewportContainer

# Godot 3 viewport input issue, for reference
# 	https://github.com/godotengine/godot/issues/26181

# this node has a minimum size 1x1 for now,
# to prevent viewport errors (due to some bug)



@onready var viewport:SubViewport = $SubViewport
@export var axis:int = Vector3.AXIS_X

#@onready var camera_scene = $SubViewport/Node2D/Camera2D

#func _process(delta):
#	print(size, "  |  ", $SubViewport.size)



func _on_redraw_request():
#	print("doing queued redrawing")
	%brushwork.queue_redraw()


func _on_update_gizmos_request():
	%gizmos.queue_redraw()


func _ready() -> void:
	_enable_input(false)

	# BUG WORKAROUND:
	# trigger size change, so it updates SubViewport size to match
#	size = Vector2()

#	data.connect("grid_size_changed", _on_grid_size_changed)
	relay.grid_size_changed.connect(_on_grid_size_changed)

	_on_grid_size_changed() # update at start



	relay.view_2d_redraw_request.connect(_on_redraw_request)
	relay.view_2d_update_gizmos_request.connect(_on_update_gizmos_request)

func set_axis(_axis:int) -> void:
	axis = _axis
	%brushwork.axis = _axis
	%gizmos.axis = _axis
	match _axis:
		Vector3.AXIS_X: $Label.text = "Right"
		Vector3.AXIS_Y: $Label.text = "Top"
		Vector3.AXIS_Z: $Label.text = "Front"

#func _gui_input(event: InputEvent) -> void:
#	match axis:
#		Vector3.AXIS_X: printt("Right", event)
#		Vector3.AXIS_Y: printt("Top", event)
#		Vector3.AXIS_Z: printt("Front", event)

func get_camera() -> Camera2D:
	return %camera

func _on_grid_size_changed() -> void:
	$SubViewport/Node2D/grid.queue_redraw()

func _enable_input(enable) -> void:
	%camera.set_process_input(enable)
	%camera.set_physics_process(enable)

func enable() -> void:  _enable_input(true)
func disable() -> void: _enable_input(false)


func _gui_input(event: InputEvent) -> void:

	if   event.is_action_pressed("left_click"):  process_left_click(true, event.position)
	elif event.is_action_released("left_click"): process_left_click(false, event.position)
	elif event.is_action_pressed("zoom_in"):     %camera.apply_zoom(-1, event.position)
	elif event.is_action_pressed("zoom_out"):    %camera.apply_zoom(1, event.position)
	elif event.is_action_pressed("mouse_look"):  %camera.is_panning = true
	elif event.is_action_released("mouse_look"): %camera.is_panning = false
	elif event is InputEventMouseMotion:
		if %camera.is_panning:
			%camera.offset -= event.relative / %camera.zoom
		elif left_clicking:
#			var relative:Vector2 = screen_position_to_world(event.relative)
			var relative:Vector2 = (event.relative / %camera.zoom)# * data.grid_size
#			var relative:Vector2 = (int(event.relative / data.grid_size) / %camera.zoom)# * data.grid_size

			var pos := screen_position_to_world(event.position)
			relay.view_2d_mouse_dragged.emit(axis, pos, relative)

	%camera.update_zoom()

#	if event is InputEventMouseButton:
#		if event.button_index == 1:
#			if event.pressed:
##				start_selecting(event.position)
#				relay.view_2d_mouse_pressed.emit(view_side, event.position)
#			else:
##				stop_selecting(event.position)
#				relay.view_2d_mouse_pressed.emit(view_side, event.position)


func screen_position_to_world(position:Vector2) -> Vector2:
	var half_vp_size:Vector2 = viewport.size/2
	var world_pos:Vector2 = (%camera.offset + (position - half_vp_size) / %camera.zoom) #* data.editor_unit_size
	return world_pos



var left_clicking := false
func process_left_click(pressed:bool, position:Vector2) -> void:

	# ofs.x - vp_size.x
	# to_map_x(cx) return self.worldpos - viewport_pos + cx

#	var vp_size:Vector2 = viewport.size

	var world_pos = screen_position_to_world(position)
#	world_pos.y = -world_pos.y # Y is always UP in the views

	var final_pos:Vector3
#	var end:Vector3

#	printt("axis", axis)
	match axis:
		Vector3.AXIS_X:
			final_pos = Vector3( 0, -world_pos.y, world_pos.x)
#			end   = Vector3(-0, -world_pos.y, world_pos.x)
		Vector3.AXIS_Y:
			final_pos = Vector3(world_pos.x,  0, world_pos.y)
#			end   = Vector3(world_pos.x, -0, world_pos.y)
		Vector3.AXIS_Z:
			final_pos = Vector3(world_pos.x, -world_pos.y,  0)
#			end   = Vector3(world_pos.x, -world_pos.y, -0)

#	relay.selection_ray_cast_request.emit(start, end)

	if pressed:
		left_clicking = true
		relay.view_2d_mouse_pressed.emit(axis, final_pos)
	else:
		left_clicking = false
		relay.view_2d_mouse_released.emit(axis, final_pos)
