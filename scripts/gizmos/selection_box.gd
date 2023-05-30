class_name SelectionBox extends Node3D


enum States {
	IDLE,
	SETUP_DRAG,
	DRAGGING,
	LOCKED,
}
var curr_state := States.IDLE


enum {A,B,C,D,E,F,G,H}
#var is_created := false

var p1:Vector3
var p2:Vector3

#var bb:BoundingBox

#var a:Vector3
#var b:Vector3
#var c:Vector3
#var d:Vector3
#var e:Vector3
#var f:Vector3
#var g:Vector3
#var h:Vector3
var verts:Array[Vector3]
var faces:Array[Array]

#var _backlines:DrawTool3DBackLines
#var _forelines:DrawTool3DForeLines

var dt:DrawTool3DMesh


var _face_alpha := 0.25
var _darken_factor := 0.25
var _alpha_factor := 0.45

var line_color           := Color.GRAY
var hovered_line_color   := Color.YELLOW
var selected_line_color  := Color.ORANGE_RED

var face_color      := Color(line_color, _face_alpha)
var selected_face_color := Color(selected_line_color, _face_alpha)
var hovered_face_color := Color(hovered_line_color, _face_alpha)

var line_thickness := 4

var _drag_plane:RaycastPlane

var dragged_face_idx := -1
var hovered_face_idx := -1
var last_hovered_face := -1

var _map:MapDocumentBrush

func _init(_p1:Vector3, _p2:Vector3, color:Color) -> void:
	_map = data.get_current_map()

	_drag_plane = RaycastPlane.new()
	add_child(_drag_plane)
	_drag_plane.input_event.connect(_on_drag_plane_input_event)

	dt = DrawTool3DMesh.new()
	dt.see_through = true
	dt.double_sided = true
	dt.line_color = line_color
	dt.line_thickness = 4
	dt.back_alpha = _alpha_factor
	dt.face_alpha = _face_alpha
	dt.darken_factor = _darken_factor
	add_child(dt)

	p1 = _p1
	p2 = _p2

	set_verts_from_points()

func set_verts_from_points() -> void:
	var a := Vector3( p1.x, p2.y, p1.z )
	var b := Vector3( p2.x, p2.y, p1.z )
	var c := Vector3( p2.x, p1.y, p1.z )
	var d := p1
	var e := Vector3( p1.x, p2.y, p2.z )
	var f := p2
	var g := Vector3( p2.x, p1.y, p2.z )
	var h := Vector3( p1.x, p1.y, p2.z )

	verts = [a,b,c,d,e,f,g,h]

	var west:Array[Vector3]   = [a,e,h,d]	# West
	var east:Array[Vector3]   = [f,b,c,g]	# East
	var north:Array[Vector3]  = [b,a,d,c]	# North
	var south:Array[Vector3]  = [e,f,g,h]	# South
	var top:Array[Vector3]    = [a,b,f,e]	# Top
	var bottom:Array[Vector3] = [h,g,c,d]	# Bottom

	faces = [west, east, north, south, top, bottom]

	relay.view_3d_mouse_moved.connect(_on_mouse_moved)
	relay.view_3d_mouse_pressed.connect(_on_mouse_pressed)


func clear() -> void:
	dt.clear()


func switch_state(st:States, force_change:=false) -> void:
	if st != curr_state or force_change:
		curr_state = st


func _on_mouse_moved(camera:Camera3D, position:Vector2): #, from:Vector3, dir:Vector3):

	if curr_state != States.IDLE: return
#	var verts := MeshUtils.get_cube_tris_from_points(p1, p2)
#	print("_on_mouse_moved")
#	var intersected_faces := []
	var closest_face:int = -1
	var closest_dist:float = INF

	for i in faces.size():
		var f := faces[i]

		var center:Vector3 = (f[A] + f[C]) / 2
		var unpj_center:Vector2 = camera.unproject_position(center)
		var dist := position.distance_to(unpj_center)
		if dist < closest_dist:
			closest_face = i
			closest_dist = dist

	last_hovered_face = hovered_face_idx
	hovered_face_idx = closest_face
	if hovered_face_idx != last_hovered_face:
		redraw()




func _on_mouse_pressed(camera:Camera3D, position:Vector2) -> void:
	printt("_on_mouse_pressed", curr_state)
	match curr_state:
		States.IDLE:
			start_dragging(camera, position)
			switch_state(States.DRAGGING)



func _on_drag_plane_input_event(camera:Node, event:InputEvent, click_pos:Vector3, click_normal:Vector3, shape_idx:int) -> void:
	match curr_state:
		States.IDLE:
			pass
		States.SETUP_DRAG:
			pass
		States.DRAGGING:
			if event is InputEventMouseMotion:
				drag(click_pos)
			elif event.is_action_released("editor_select"):
				commit_dragging()
		States.LOCKED:
			pass



#	if event is InputEventMouseButton:
#		if event.pressed:
#			if event.button_index == 1:
#				start_dragging(curr_pos)
##			elif event.button_index == 2:
##				cancel_selection()
#			pass
#		else:
##			commit_selection(curr_pos)
#			pass
#		pass


func _awake_drag_plane() -> void:
#	_coll_plane.input_ray_pickable = true

	var center := (p1 + p2) / 2
	# print(_current_face)
	match hovered_face_idx:
		MeshUtils.WEST, MeshUtils.EAST:   _drag_plane.wake(center, RaycastPlane.X)
		MeshUtils.NORTH, MeshUtils.SOUTH: _drag_plane.wake(center, RaycastPlane.Z)
		MeshUtils.TOP, MeshUtils.BOTTOM:  _drag_plane.wake(center, RaycastPlane.Y)



var drag_data:Dictionary
func start_dragging(camera:Camera3D, position:Vector2) -> void:
	dragged_face_idx = hovered_face_idx

	var overts:Array[Vector3] = []
	for v in verts:
		overts.append(v)

	var ofaces:Array[Array]
	for f in faces:
		var fv:Array[Vector3] = []
		for v in f:
			fv.append(v)
		ofaces.append(fv)

	drag_data.original_verts = overts
	drag_data.original_faces = ofaces
	drag_data.start_pos = position

	_awake_drag_plane()

	switch_state(States.DRAGGING)
	drag(Vector3(position.x, 0, position.y))



func clear_dragging() -> void:
	dragged_face_idx = -1
	drag_data.clear()
	_drag_plane.sleep()

func commit_dragging() -> void:
	clear_dragging()
	switch_state(States.IDLE)

func cancel_dragging() -> void:
	for i in drag_data.original_verts.size():
		var v:Vector3 = drag_data.original_verts[i]
		verts[i] = v
	clear_dragging()
	switch_state(States.IDLE)
	redraw()


func drag(end_pos:Vector3) -> void:
	var grid:Vector3 = Vector3.ONE * _map.grid_size

	var start_snapped:Vector3 = drag_data.start.snapped(grid)
	var end_snapped := end_pos.snapped(grid)
	var diff_snapped := end_snapped - start_snapped

	var ofaces:Array[Array] = drag_data.original_faces
	var osf := ofaces[dragged_face_idx]
	var sf := faces[dragged_face_idx]
	for i in sf.size():
		var v:Vector3 = osf[i] + diff_snapped
		sf[i] = v

#	var overts:Array[Vector3] = drag_data.original_verts
#	for i in verts.size():
#		var v := overts[i] + diff_snapped
#
#		verts[i] = v # * _map.grid_size

	redraw()


func redraw() -> void:
	dt.clear()

	for i in faces.size():
		var f = faces[i]
		var fverts = f + [f[A]]
		if i == dragged_face_idx:
			dt.polyline(fverts, selected_line_color, line_thickness+1)
			dt.draw_quad(f, selected_face_color)
		elif i == hovered_face_idx:
			dt.polyline(fverts, hovered_line_color, line_thickness+1)
			dt.draw_quad(f, hovered_face_color)
		else:
			dt.polyline(fverts)
			dt.draw_quad(f)#, face_color)


#func commit() -> void:
#	is_created = true
#	# create 6 face handles
#
#	# 2d views need 8 handles: 4 edge handles, and 4 vertex handles
#
#	relay.view_3d_mouse_moved.connect(_on_mouse_moved)




