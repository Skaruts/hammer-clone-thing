class_name Brush extends StaticBody3D

var _map:MapDocumentBrush

var id:int    # this is just stupid... should be able to bypass getter/setter and not need two vars
#var id:int:
#	get: return _id
#	set(new_id):
#		_id = new_id
#		name = "brush_" + str(id)

var verts:Array[Vertex]
var faces:Array[Face]
var edges:Array[Edge]
var faces_by_material:Dictionary = {}

var lock_material := false
var selected := false

var mi:MeshInstance3D
var mesh:ArrayMesh

var coll:CollisionShape3D
var bb_color := Color("acff00")



var drag_data := {}
var sel_lines:SelectionLines

func _init(map:MapDocumentBrush, _id:int, material:StandardMaterial3D, _verts:Array[Vertex], _faces:Array[Face], _edges:Array[Edge]):
	_map = map

	id = _id
	name = "brush_" + str(_id)

	verts = _verts
	faces = _faces
	edges = _edges

	sel_lines = SelectionLines.new(data.color_brush_selected, data.color_brush_selected_behind)
	add_child(sel_lines)

	mi = MeshInstance3D.new()
	add_child(mi)
#	mi.material_overlay = StandardMaterial3D.new()
#	mi.material_overlay.flags_transparent = true
#	mi.material_overlay.albedo_color = color_deselected

	coll = CollisionShape3D.new()
	add_child(coll)

	faces_by_material[material] = faces.duplicate()
	rebuild_mesh()


func get_aabb() -> AABB:
	return mi.mesh.get_aabb()


func rebuild_mesh():
	var mesh_infos = []
	for fmat in faces_by_material:
		var face_array = faces_by_material[fmat]
		for f in face_array:
			var fverts   = f.get_tri_vectors()
			var fuvs     = f.get_uvs()
			var fnormals = f.get_vert_normals()

			mesh_infos.append({
				material       = fmat,
				primitive_type = Mesh.PRIMITIVE_TRIANGLES,
				vertices       = fverts,
				uvs            = fuvs,
				normals        = fnormals,
			})

	mesh = MeshUtils.build_mesh(mesh_infos)
	mi.mesh = mesh
	coll.shape = mi.mesh.create_convex_shape()

	if selected:
		draw_selection_lines()

	relay.view_2d_redraw_request.emit()


func nudge(units:Vector3):
	for v in verts:
		v.vec += units * _map.grid_size

	rebuild_mesh()






func start_dragging(start:Vector3, end:Vector3) -> void:
	var overts:Array[Vertex] = []
	for v in verts:
		overts.append(Vertex.new(v.vec))

	drag_data.original_verts = overts
#	drag_data.original_verts = verts.duplicate()
	drag_data.start = start
	drag(end)


func commit_dragging() -> void:
	drag_data.clear()


func cancel_dragging() -> void:
	for i in drag_data.original_verts.size():
		var v:Vertex = drag_data.original_verts[i]
		verts[i].vec = v.vec
	drag_data.clear()
	rebuild_mesh()


func drag(end:Vector3) -> void:
	var grid := Vector3.ONE * _map.grid_size

	var start_snapped:Vector3 = drag_data.start.snapped(grid)
	var end_snapped := end.snapped(grid)
	var diff_snapped := end_snapped - start_snapped

	var overts:Array[Vertex] = drag_data.original_verts

	for i in verts.size():
		var v := overts[i].vec + diff_snapped

		verts[i].vec = v # * _map.grid_size

	rebuild_mesh()


func draw_selection_lines() -> void:
	sel_lines.clear()
	sel_lines.draw(edges)


func clear_selection_lines() -> void:
	sel_lines.clear()


func select() -> void:
	selected = true
	draw_selection_lines()

func deselect() -> void:
	selected = false
	clear_selection_lines()

