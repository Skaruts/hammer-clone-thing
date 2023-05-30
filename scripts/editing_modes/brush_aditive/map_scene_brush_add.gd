extends Node3D


# brushes should be simple data structs

# this class should keep a list of them

# take that list and populate a single ArrayMesh
# 	- each surface of the mesh corresponds to a material ?

# mouse clicks should be determined by casting a ray
# and manually calculating intersections (see old projects for how)
# Only the closest brush should ever be selected
# (no selecting brushes in the back, only in 2D views, unless I decide to have a special key to turn on back-selection mode)

# for performance, later on, perhaps have more ArrayMeshes for
# separate chunks of the 3D space, or leaves in an oct-tree


var mesh:ArrayMesh
var brush:Brush

var mi:MeshInstance3D
var dt:DrawTool3DMesh
var map:MapDocumentBrush

var tool_select:SelectTool
#var tool_brush:EditorTool
#var tool_vertex:EditorTool
#var tool_face:EditorTool
#var tool_edge:EditorTool

var curr_tool:EditorTool

func _ready():
	map = data.create_map()
	add_child(map)

	dt = DrawTool3DMesh.new()
	dt.transparent = true
	add_child(dt)

	tool_select = SelectTool.new(map)
	add_child(tool_select)

	curr_tool = tool_select

	relay.selection_ray_cast_request.connect(_on_raycast_request)

	$fly_camera.set_orientation(
		Vector3(-2, 3, 5),
		Vector3(-20, -30, 0)
	)

	# this is in game units (not editor (godot) units)
	var brush_specs:Array = [
		[Vector3(0, 0, 0), Vector3(256, 32, 96)],
		[Vector3(-32, -64, 40), Vector3(256, 32, 96)],
		[Vector3(-64, -100, -200), Vector3(256, 32, 400)],
		[Vector3(-128, -100, -16), Vector3(256, 200, 32)],
	]

	for bs in brush_specs:
		var pos:Vector3 = bs[0]
		var size:Vector3 = bs[1]
		map.create_brush_at_points(pos, pos+size)
	brush = map.brushes[0]

#	var p1 := Vector3(-2, -2, -2)
	var p2 := Vector3(2, 2, 2)
#	dt.cube_faces(p1, p2, Color("ff801030"))
#	dt.cube_lines(p1, p2, Color("ff8010"), 5)
	dt.text(p2, "FOOOOO!!!", Color.RED, 5)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# TODO: this isn't working properly
		%"3d_direction_gizmo".rotation = $fly_camera.get_curr_rotation()
	else:

		if event.is_action_pressed("nudge_left"):  nudge_brushes(Vector3(-1,  0,  0))
		if event.is_action_pressed("nudge_right"): nudge_brushes(Vector3( 1,  0,  0))
		if event.is_action_pressed("nudge_up"):	   nudge_brushes(Vector3( 0,  0, -1))
		if event.is_action_pressed("nudge_down"):  nudge_brushes(Vector3( 0,  0,  1))


func nudge_brushes(direction:Vector3) -> void:
	if not map.selected_brushes.size(): return
	for b in map.selected_brushes:
		b.nudge(direction)

	pass


func _on_raycast_request(start, end):
	var a:Vector3 = start * data.editor_unit_size
	var b:Vector3 = end   * data.editor_unit_size

	debug.draw_line(a, b, Color.WHITE, 5, "foo")
	dt.line(a, b, Color.ORANGE, 3)



#func _on_view_2d_mouse_pressed(facing:data.ViewSide, start:Vector3, end:Vector3):
##	var real_position = get_click_position(facing, world_position)
#
#	curr_tool.on_2d_mouse_pressed(facing, start, end)




#func _on_view_2d_mouse_released(facing:data.ViewSide, start:Vector3, end:Vector3):
##	var real_position = get_click_position(facing, world_position)
#	curr_tool.on_2d_mouse_released(facing, start, end)
##	match data.curr_tool_mode:
##		data.ToolMode.SELECT:
##			$RayCast3D.position = start
##			$RayCast3D.target_position = end
##			$RayCast3D.force_raycast_update()
##
##			if $RayCast3D.is_colliding():
##				var collider = $RayCast3D.get_collider()
##				printt("COLLIDED!", collider)
##
##		data.ToolMode.BRUSH:
##			pass
##		data.ToolMode.ENTITY:
##			pass
##		data.ToolMode.VERTEX:
##			pass
##		data.ToolMode.EDGE:
##			pass
##		data.ToolMode.FACE:
##			pass
#
#
#
#
#func _on_view_2d_mouse_dragged(facing:data.ViewSide, relative:Vector2):
#	curr_tool.on_2d_mouse_dragged(facing, relative)
#	pass
