class_name MapDocumentBrush
extends MapDocument


# The base planes where a brush will be created on, depending on the
# 2d view that was clicked. E.g, clicking the top view will create
# a brush at the Y value in 'curr_base_planes'.
var curr_base_planes := Vector3()


var brushes:Array[Brush] = []
var point_entities:Array = []
var brush_entities:Array = []
var selected_brushes:Array[Brush] = []
var last_selected_brushes:Array[Brush] = []
var _brush_id := -1


#var last_selected_entity:Entity

var selection_box:SelectionBox
var selection_bb:BoundingBox

var dt:DrawTool3DMesh

func _ready() -> void:
	dt = DrawTool3DMesh.new()
	dt.on_top = true
	dt.transparent = false
#	dt.single_color = true
#	dt.line_color = Color.RED
	add_child(dt)

func get_grid_snap_vector_3d() -> Vector3:
	return Vector3(grid_size, grid_size, grid_size)

func get_grid_snap_vector_2d() -> Vector2:
	return Vector2(grid_size, grid_size)

func create_selection_box(p1:Vector3, p2:Vector3) -> void:
	if selection_bb != null or selection_box != null:
		cancel_selection_box()

	selection_bb = BoundingBox.new(Color.GREEN_YELLOW)
	add_child(selection_bb)
	printt(create_selection_box, p1, p2)
	selection_bb.draw(p1*data.editor_unit_size, p2*data.editor_unit_size)
	relay.view_2d_update_gizmos_request.emit()

func draw_selection_box(p1:Vector3, p2:Vector3):
	assert(selection_bb != null)
	selection_bb.clear()
	selection_bb.draw(p1*data.editor_unit_size, p2*data.editor_unit_size)
	relay.view_2d_update_gizmos_request.emit()

func cancel_selection_box():
	if selection_bb != null:
		selection_bb.queue_free()
		selection_bb = null
	if selection_box != null:
		selection_box.queue_free()
		selection_box = null
	relay.view_2d_update_gizmos_request.emit()

func commit_selection_box():
	assert(selection_bb != null)
	var p1 := selection_bb.p1
	var p2 := selection_bb.p2
	selection_box = SelectionBox.new(p1, p2, Color.GREEN_YELLOW)
	add_child(selection_box)
	selection_box.redraw()
	selection_bb.queue_free()
	selection_bb = null
	relay.view_2d_update_gizmos_request.emit()


func _next_brush_id():
	_brush_id += 1
	return _brush_id

func select_brush(b:Brush) -> void:
	if not selected_brushes.size():
		last_selected_brushes.clear()
	selected_brushes.append(b)
	last_selected_brushes.append(b)
	b.select()
	relay.view_2d_redraw_request.emit()


func deselect_brush(b:Brush) -> void:
	selected_brushes.erase(b)
	b.deselect()
	if last_selected_brushes.size() > 1:
		last_selected_brushes.erase(b)
	relay.view_2d_redraw_request.emit()


func select_none() -> void:
	for b in selected_brushes:
		b.deselect()
	selected_brushes.clear()
	relay.view_2d_redraw_request.emit()


func create_brush_at_points(p1:Vector3, p2:Vector3) -> Brush:
#	p1 = p1 * data.editor_unit_size
#	p2 = p2 * data.editor_unit_size

#	var verts = MeshUtils.get_cube_verts_from_points(a, b)
	var mat := MeshUtils.new_texture_material(ResourceLoader.load("res://icon.svg"))

	var brush := BrushFactory.create_brush_at_points(self, _next_brush_id(), p1, p2, mat)

	brushes.append(brush)
	add_child(brush)
#	select_brush(brush)
	return brush



func get_non_selected_brushes():
	var arr:Array[Brush] = brushes.filter(func(b): return b.selected != true)
	return arr


func get_position_in_curr_plane(axis:int, pos:Vector3, closest:bool) -> Vector3:
	var plane_pos := Vector3()
	var aabb:AABB

	if last_selected_brushes.size():
		for b in last_selected_brushes:
#			print(b.get_aabb())
			if aabb == AABB():
				aabb = b.get_aabb()
			else:
				aabb = aabb.merge(b.get_aabb())

	var point := BrushUtils.eu_to_gu(aabb.end if closest else aabb.position)

	match axis:
		Vector3.AXIS_X:	plane_pos = Vector3(point.x,  pos.y, pos.z)
		Vector3.AXIS_Y:	plane_pos = Vector3(pos.x, point.y,  pos.z)
		Vector3.AXIS_Z:	plane_pos = Vector3(pos.x, pos.y, point.z)

#	printt("last_selected_brushes", last_selected_brushes, plane_pos)
	return plane_pos
