class_name SelectTool extends EditorTool

enum SelectStates {
	NONE,
	CLICKING,
	DRAGGING_BRUSHES,
	DRAGGING_SELECTION,
	BOX_SELECTED,
	LOCKED,
}
var curr_state := SelectStates.NONE


var start_position:Vector3
var end_position:Vector3

var selection_box

var ray:RayCast3D
var dt:DrawTool3DMesh


var prev_colliders_size := 0
var ray_colliders:Array[Brush] = []

var curr_collider_index := 0


func _init(map:MapDocumentBrush) -> void:
	super(map)
	dt = DrawTool3DMesh.new()
	add_child(dt)

	ray = RayCast3D.new()
	ray.enabled = true
	ray.debug_shape_custom_color = Color.GREEN_YELLOW
	ray.debug_shape_thickness = 5
	add_child(ray)

	relay.view_2d_mouse_pressed.connect(_on_view_2d_mouse_pressed)
	relay.view_2d_mouse_released.connect(_on_view_2d_mouse_released)
	relay.view_2d_mouse_dragged.connect(_on_view_2d_mouse_dragged)


func _unhandled_input(event: InputEvent) -> void:
	match curr_state:
		SelectStates.NONE:
			if event.is_action_pressed("ui_cancel") \
			and map.selected_brushes.size():
				clear_selection()

		SelectStates.DRAGGING_BRUSHES:
			if event.is_action_pressed("cancel_brush_dragging"):
				for b in map.selected_brushes:
					b.cancel_dragging()
				switch_state(SelectStates.LOCKED)
		SelectStates.DRAGGING_SELECTION:
			if event.is_action_pressed("cancel_brush_dragging"):
				cancel_selection()
				switch_state(SelectStates.LOCKED)
		SelectStates.BOX_SELECTED:
			if event.is_action_pressed("ui_cancel"):
				cancel_selection()
				switch_state(SelectStates.NONE)

func get_real_position(world_position:Vector3) -> Vector3:
	return world_position * data.editor_unit_size


#func get_position_in_curr_plane(axis:int, pos:Vector3) -> Vector3:
#	var plane_pos:Vector3
#	var planes := map.curr_base_planes
#
#
#
#	match axis:
#		Vector3.FRONT:
#			plane_pos = Vector3(pos.x, pos.y, planes.z)
#		Vector3.RIGHT:
#			plane_pos = Vector3(planes.x,  pos.y, pos.z)
#		Vector3.TOP:
#			plane_pos = Vector3(pos.x, planes.y,  pos.z)
#	return plane_pos


func cast_ray(axis:int, start:Vector3) -> void:
	var real_start := get_real_position(start)

	match axis:
		Vector3.AXIS_X: # right
			ray.position = Vector3(data.HUGE, real_start.y, real_start.z)
			ray.target_position = Vector3(-data.HUGE*2, 0, 0)
		Vector3.AXIS_Y: # top
			ray.position = Vector3(real_start.x, data.HUGE, real_start.z)
			ray.target_position = Vector3(0, -data.HUGE*2, 0)
		Vector3.AXIS_Z: # front
			ray.position = Vector3(real_start.x, real_start.y, data.HUGE)
			ray.target_position = Vector3(0, 0, -data.HUGE*2)

	ray.force_raycast_update()
	#		relay.selection_ray_cast_request.emit(start, end)
#		dt.line(real_start, real_end, Color.YELLOW, 3)
#		debug.draw_line(real_start, real_end, Color.RED, 10, "foo")

func clear_selection() -> void:
	map.select_none()
	ray_colliders.clear()
	prev_colliders_size = 0
	curr_collider_index = 0


func reset_collider_index() -> void:
	curr_collider_index = 0

func increase_collider_index() -> void:
	curr_collider_index += 1
	if curr_collider_index >= ray_colliders.size():
		curr_collider_index = 0




func switch_state(st:SelectStates, force_switch:= false) -> void:
	if st != curr_state or force_switch:
		curr_state = st


func _on_view_2d_mouse_pressed(_axis:int, position:Vector3) -> void:
	match curr_state:
		SelectStates.NONE:
			start_position = position
			end_position   = position
#			check_ray_collisions(axis, start_position)
			switch_state(SelectStates.CLICKING)






@warning_ignore("unused_parameter")
func _on_view_2d_mouse_released(axis:int, position:Vector3) -> void:
	# if start and end positions are the same, cast ray
	# else, cast shape

	match curr_state:
		SelectStates.CLICKING:
			if start_position == end_position:
#				check_ray_collisions(axis, start_position, end_position)
				check_ray_collisions(axis, start_position)
#				printt(curr_state, ray_colliders.size())
				if ray_colliders.size():
					select_next_brush()
				else:
					# user clicked away, so clear everything
					printt("clicked away")
					clear_selection()
			switch_state(SelectStates.NONE)
		SelectStates.DRAGGING_BRUSHES:
			for b in map.selected_brushes:
				b.commit_dragging()
			switch_state(SelectStates.NONE)
		SelectStates.DRAGGING_SELECTION:
			commit_selection()
			switch_state(SelectStates.BOX_SELECTED)
		SelectStates.LOCKED:
			switch_state(SelectStates.NONE)







func _on_view_2d_mouse_dragged(axis:int, position:Vector2, _relative:Vector2) -> void:
	match axis:
		Vector3.AXIS_X: end_position = Vector3(0, -position.y, position.x)
		Vector3.AXIS_Y: end_position = Vector3(position.x, 0, position.y)
		Vector3.AXIS_Z: end_position = Vector3(position.x, -position.y, 0)

	match curr_state:
		SelectStates.CLICKING:
			if ray_colliders.size():
				for b in map.selected_brushes:
					b.start_dragging(start_position, end_position)
				switch_state(SelectStates.DRAGGING_BRUSHES)
			else:
				start_selection(axis)
				switch_state(SelectStates.DRAGGING_SELECTION)
		SelectStates.DRAGGING_BRUSHES:
			for b in map.selected_brushes:
				b.drag(end_position)
		SelectStates.DRAGGING_SELECTION:
			drag_selection(axis)



func check_ray_collisions(axis:int, start:Vector3) -> bool:
	var real_start := get_real_position(start)

	cast_ray(axis, start)
	var colliders:Array[Brush]
	if ray.is_colliding():
#		ray_colliders.clear()
		printt("ray is colliding")
#		if not ray_colliders.size():
		while ray.is_colliding():
			var brush = ray.get_collider()
			colliders.append(brush)
			ray.add_exception(brush)
			cast_ray(axis, start)
		ray.clear_exceptions()

		match axis:
			Vector3.AXIS_X: # right
				ray_colliders = BrushUtils.sort_brushes_by_edge_proximity_side_facing(colliders, real_start)
			Vector3.AXIS_Y: # top
				ray_colliders = BrushUtils.sort_brushes_by_edge_proximity_top_facing(colliders, real_start)
			Vector3.AXIS_Z: # front
				ray_colliders = BrushUtils.sort_brushes_by_edge_proximity_front_facing(colliders, real_start)

		if ray_colliders.size() != prev_colliders_size\
		or curr_collider_index >= ray_colliders.size():
			curr_collider_index = 0

		prev_colliders_size = ray_colliders.size()

#		printt(curr_collider_index, ray_colliders)
		return true

	else:
		ray_colliders.clear()
		curr_collider_index = 0
		return false



func select_next_brush():
	map.select_none()
	map.select_brush(ray_colliders[curr_collider_index])
	increase_collider_index()


func start_selection(axis:int):
	var snap := map.get_grid_snap_vector_3d()
	var p1 := map.get_position_in_curr_plane(axis, start_position, false).snapped(snap)
	var p2 := map.get_position_in_curr_plane(axis, end_position, true).snapped(snap)
	map.create_selection_box(p1, p2)


func drag_selection(axis:int) -> void:
	var snap := map.get_grid_snap_vector_3d()
	var p1 := map.get_position_in_curr_plane(axis, start_position, false).snapped(snap)
	var p2 := map.get_position_in_curr_plane(axis, end_position, true).snapped(snap)
	map.draw_selection_box(p1, p2)


func cancel_selection() -> void:
	map.cancel_selection_box()



func commit_selection() -> void:
	map.commit_selection_box()

