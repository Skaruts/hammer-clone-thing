extends RefCounted
class_name Face

var verts:Array[Vertex]
var edges:Array[Edge]
var normal:Vector3
var material:StandardMaterial3D
#var w
#var h

enum {A,B,C,D}

func _init(_verts:Array[Vertex], mat:StandardMaterial3D) -> void:
	verts = _verts

	material = mat

#	edges.append(Edge.new(verts[A], verts[B]))
#	edges.append(Edge.new(verts[B], verts[C]))
#	edges.append(Edge.new(verts[C], verts[D]))
#	edges.append(Edge.new(verts[D], verts[A]))

#	w = abs(verts[0] - verts[1])
#	h = abs(verts[0] - verts[3])
	calculate_normal()


func calculate_normal() -> void:
	normal = Plane(verts[0].vec, verts[1].vec, verts[2].vec).normal


func get_tri_vectors():
	return PackedVector3Array([
		verts[0].vec * data.editor_unit_size,
		verts[1].vec * data.editor_unit_size,
		verts[2].vec * data.editor_unit_size,
		verts[0].vec * data.editor_unit_size,
		verts[2].vec * data.editor_unit_size,
		verts[3].vec * data.editor_unit_size,
	])

func get_uvs():
#	var uvs = MeshUtils.get_cube_uvs_from_quads(_faces, )
	@warning_ignore("unused_variable")
	var unit = data.editor_unit_size
	var uvs = []

	var mat_size:Vector2 = material.albedo_texture.get_size()

	match normal:
		Vector3.LEFT, Vector3.RIGHT:         #west, east
			for v in verts:
#				var uv = Vector2(v.z+unit, -v.y+unit)
#				var uv = Vector2(v.z, -v.y) * unit
				var uv = Vector2(v.z, -v.y) / mat_size #/ unit
				uvs.append(uv)
		Vector3.FORWARD, Vector3.BACK:       # north, south
			for v in verts:
#				var uv = Vector2(v.x+unit, -v.y+unit)
				var uv = Vector2(v.x, -v.y) / mat_size #/ unit
				uvs.append(uv)
		Vector3.UP, Vector3.DOWN:            # top, bottom
			for v in verts:
#				var uv = Vector2(v.x+unit, v.z+unit)
				var uv = Vector2(v.x, v.z) / mat_size #/ unit
				uvs.append(uv)

	return PackedVector2Array([uvs[0], uvs[1], uvs[2], uvs[0], uvs[2], uvs[3]])


func get_vert_normals():
	return PackedVector3Array([normal, normal, normal, normal, normal, normal])
