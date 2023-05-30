extends SubViewportContainer

# Godot 3 viewport input issue, for reference
# 	https://github.com/godotengine/godot/issues/26181

# this node has a minimum size 1x1 for now,
# to workaround vulkan viewport errors


#@onready var camera_scene = $"SubViewport/3d_scene/fly_camera"
var camera_scene:CharacterBody3D

const draw_modes:Array[String] = ["normal", "unshaded", "solid", "overdraw", "wireframe"]
@export_range(0, 4, 1) var draw_mode := Viewport.DEBUG_DRAW_DISABLED:
	set(mode):
		draw_mode = mode
		if is_inside_tree():
			$SubViewport.debug_draw = mode
	get:
		return draw_mode
#		return $SubViewport.debug_draw


func _ready() -> void:
	camera_scene = $SubViewport.get_children()[0].get_node("fly_camera")
	_enable_input(false)

	$SubViewport.debug_draw = draw_mode
	size = Vector2()


func _enable_input(enable):
	camera_scene.set_process_input(enable)
	camera_scene.set_physics_process(enable)


func enable():  _enable_input(true)
func disable(): _enable_input(false)


func get_camera():
	return camera_scene




func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
#
#		var from:Vector3 = camera_scene.camera.project_ray_origin(event.position)
#		var dir:Vector3 = camera_scene.camera.project_ray_normal(event.position) #* 9999999
#		printt("_gui_input", from, dir)
		relay.view_3d_mouse_moved.emit(camera_scene.camera, event.position)
	elif event.is_action_pressed("editor_select"):
		relay.view_3d_mouse_pressed.emit(camera_scene.camera, event.position)



##			var relative:Vector2 = screen_position_to_world(event.relative)
#			var relative:Vector2 = (event.relative / %camera.zoom)# * data.grid_size
##			var relative:Vector2 = (int(event.relative / data.grid_size) / %camera.zoom)# * data.grid_size
#
#			var pos := screen_position_to_world(event.position)
#			relay.view_2d_mouse_dragged.emit(axis, pos, relative)
#
#	%camera.update_zoom()
