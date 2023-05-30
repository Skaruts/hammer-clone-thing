class_name MeshUtils extends Object

# version 0.7.3 (Godot 4)

#               010           110                         Z
#   Vertices     A0 ---------- B1            Faces      Top    -Y
#           011 /  |      111 /  |                        |   North
#             E4 ---------- F5   |                        | /
#             |    |        |    |          -X West ----- 0 ----- East X
#             |   D3 -------|-- C2                      / |
#             |  /  000     |  / 100               South  |
#             H7 ---------- G6                      Y    Bottom
#              001           101                          -Z

const NONE = -1

# cube geometry
enum { WEST, EAST, NORTH, SOUTH, TOP, BOTTOM, MAX_FACES }
enum { AB, BF, FE, EA, DC, CG, GH, HD, AD, BC, FG, EH, MAX_EDGES }
enum { A, B, C, D, E, F, G, H, MAX_VERTICES }

# 3d space
enum { X, Y, Z, XY, XZ, YZ }
enum { VERTEX, EDGE, FACE }

enum {
	MAT_DEFAULT      = 0,
	MAT_UNSHADED     = 1,
	MAT_TRANSPARENT  = 2,
	MAT_ON_TOP       = 4,
	MAT_DOUBLE_SIDED = 8,
	MAT_FIXED_SIZE   = 16,
	MAT_ALL          = 31,
}

enum {
	MAT_BLEND_MIX = StandardMaterial3D.BLEND_MODE_MIX,
	MAT_BLEND_ADD = StandardMaterial3D.BLEND_MODE_ADD,
	MAT_BLEND_MUL = StandardMaterial3D.BLEND_MODE_MUL,
	MAT_BLEND_SUB = StandardMaterial3D.BLEND_MODE_SUB,
}




#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#			Material functions

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
static func new_material(_thickness:=1, flags:=MAT_DEFAULT, blend_mode:=MAT_BLEND_MIX) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
#	mat.params_line_width   = thickness
	mat.params_cull_mode    = StandardMaterial3D.CULL_DISABLED if flags & MAT_DOUBLE_SIDED else StandardMaterial3D.CULL_BACK
	mat.flags_unshaded      = flags & MAT_UNSHADED
#	mat.shading_mode        = BaseMaterial3D.SHADING_MODE_PER_PIXEL #mat.SHADING_MODE_UNSHADED if flags & MAT_UNSHADED else mat.SHADING_MODE_PER_PIXEL
	mat.flags_no_depth_test = flags & MAT_ON_TOP
	mat.flags_transparent   = flags & MAT_TRANSPARENT
#	mat.flags_fixed_size    = flags & MAT_FIXED_SIZE
	mat.params_blend_mode   = blend_mode
	return mat

# thickness is currently not working in GLES2
static func new_color_material(color:=Color.WHITE, thickness:=1, flags:=MAT_DEFAULT, blend_mode:=MAT_BLEND_MIX) -> StandardMaterial3D:
	var mat = MeshUtils.new_material(thickness, flags, blend_mode)
	mat.albedo_color = color
	return mat

static func new_texture_material(texture:Texture2D, thickness:=1, flags:=MAT_DEFAULT, blend_mode:=MAT_BLEND_MIX) -> StandardMaterial3D:
	var mat = MeshUtils.new_material(thickness, flags, blend_mode)
	mat.albedo_texture = texture
	return mat




#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#			Mesh functions

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
const OPPOSITES := [EAST, WEST, SOUTH, NORTH, BOTTOM, TOP]

static func get_opposite_cube_quad_index(idx:int) -> int:
	assert(idx >= 0 and idx < 6)
	return OPPOSITES[idx]
	# match idx:
	# 	WEST:   return EAST
	# 	EAST:   return WEST
	# 	NORTH:  return SOUTH
	# 	SOUTH:  return NORTH
	# 	TOP:    return BOTTOM
	# 	BOTTOM: return TOP
	# return -1


static func get_cube_outward_quad_inds() -> Array:
	return [
		[A, E, H, D],  # 0 4 7 3  |  0  |  West
		[F, B, C, G],  # 5 1 2 6  |  1  |  East
		[B, A, D, C],  # 1 0 3 2  |  2  |  North
		[E, F, G, H],  # 4 5 6 7  |  3  |  South
		[A, B, F, E],  # 0 1 5 4  |  4  |  Top
		[H, G, C, D],  # 7 6 2 3  |  5  |  Bottom
	]


static func get_cube_outward_tri_verts(verts:Array[Vector3]) -> PackedVector3Array:
	var a:Vector3 = verts[A];    var b:Vector3 = verts[B];
	var c:Vector3 = verts[C];    var d:Vector3 = verts[D];
	var e:Vector3 = verts[E];    var f:Vector3 = verts[F];
	var g:Vector3 = verts[G];    var h:Vector3 = verts[H];

	return PackedVector3Array([
		a,e,h, a,h,d,  # West
		f,b,c, f,c,g,  # East
		b,a,d, b,d,c,  # North
		e,f,g, e,g,h,  # South
		a,b,f, a,f,e,  # Top
		h,g,c, h,c,d,  # Bottom
	])


static func get_cube_outward_tri_inds() -> PackedInt32Array:
	return PackedInt32Array([
		A,E,H,  A,H,D,  # West
		F,B,C,  F,C,G,  # East
		B,A,D,  B,D,C,  # North
		E,F,G,  E,G,H,  # South
		A,B,F,  A,F,E,  # Top
		H,G,C,  H,C,D,  # Bottom
	])


static func get_cube_verts_from_position(p:=Vector3.ZERO) -> Array:
	return [
		Vector3(0, 1, 0) + p,
		Vector3(1, 1, 0) + p,
		Vector3(1, 0, 0) + p,
		Vector3(0, 0, 0) + p,
		Vector3(0, 1, 1) + p,
		Vector3(1, 1, 1) + p,
		Vector3(1, 0, 1) + p,
		Vector3(0, 0, 1) + p,
	]


static func get_cube_verts_from_points(a:Vector3, b:Vector3) -> Array[Vector3]:
	return [
		Vector3( a.x, b.y, a.z ),
		Vector3( b.x, b.y, a.z ),
		Vector3( b.x, a.y, a.z ),
		a,
		Vector3( a.x, b.y, b.z ),
		b,
		Vector3( b.x, a.y, b.z ),
		Vector3( a.x, a.y, b.z ),
	]


static func get_cube_tris_from_points(p1:Vector3, p2:Vector3) -> PackedVector3Array:
	var a := Vector3( p1.x, p2.y, p1.z )
	var b := Vector3( p2.x, p2.y, p1.z )
	var c := Vector3( p2.x, p1.y, p1.z )
	var d := p1
	var e := Vector3( p1.x, p2.y, p2.z )
	var f := p2
	var g := Vector3( p2.x, p1.y, p2.z )
	var h := Vector3( p1.x, p1.y, p2.z )

	return PackedVector3Array([
		a,e,h, a,h,d,  # West
		f,b,c, f,c,g,  # East
		b,a,d, b,d,c,  # North
		e,f,g, e,g,h,  # South
		a,b,f, a,f,e,  # Top
		h,g,c, h,c,d,  # Bottom
	])

static func get_cube_quads_from_points(a:Vector3, b:Vector3) -> Array[Array]:
	var verts := get_cube_verts_from_points(a, b)
	var faces := get_cube_outward_quads_from_8_verts(verts)
	return faces

static func get_cube_edges_from_points(p1:Vector3, p2:Vector3) -> Array:
#	enum { AB, BF, FE, EA, DC, CG, GH, HD, AD, BC, FG, EH, MAX_EDGES }
	var a := Vector3( p1.x, p2.y, p1.z )
	var b := Vector3( p2.x, p2.y, p1.z )
	var c := Vector3( p2.x, p1.y, p1.z )
	var d := p1
	var e := Vector3( p1.x, p2.y, p2.z )
	var f := p2
	var g := Vector3( p2.x, p1.y, p2.z )
	var h := Vector3( p1.x, p1.y, p2.z )

	return [
		[a,b],[b,f],[f,e],[e,a],
		[d,c],[c,g],[g,h],[h,d],
		[a,d],[b,c],[f,g],[e,h],
	]

static func get_cube_outward_quads_from_8_verts(verts:Array) -> Array[Array]:
	var a:Vector3 = verts[A];    var b:Vector3 = verts[B];
	var c:Vector3 = verts[C];    var d:Vector3 = verts[D];
	var e:Vector3 = verts[E];    var f:Vector3 = verts[F];
	var g:Vector3 = verts[G];    var h:Vector3 = verts[H];

	return [
		[a,e,h,d],  # West
		[f,b,c,g],  # East
		[b,a,d,c],  # North
		[e,f,g,h],  # South
		[a,b,f,e],  # Top
		[h,g,c,d],  # Bottom
	]

static func get_cube_outward_normals() -> PackedVector3Array:
	return PackedVector3Array([
		Vector3.LEFT, Vector3.LEFT, Vector3.LEFT, Vector3.LEFT, Vector3.LEFT, Vector3.LEFT,
		Vector3.RIGHT, Vector3.RIGHT, Vector3.RIGHT, Vector3.RIGHT, Vector3.RIGHT, Vector3.RIGHT,
		Vector3.FORWARD, Vector3.FORWARD, Vector3.FORWARD, Vector3.FORWARD, Vector3.FORWARD, Vector3.FORWARD,
		Vector3.BACK, Vector3.BACK, Vector3.BACK, Vector3.BACK, Vector3.BACK, Vector3.BACK,
		Vector3.UP, Vector3.UP, Vector3.UP, Vector3.UP, Vector3.UP, Vector3.UP,
		Vector3.DOWN, Vector3.DOWN, Vector3.DOWN, Vector3.DOWN, Vector3.DOWN, Vector3.DOWN,
	])

static func get_cube_uvs() -> PackedVector2Array:
	var face_uvs := [Vector2(0,0), Vector2(1,0), Vector2(1,1), Vector2(0,0), Vector2(1,1), Vector2(0,1)]
	return PackedVector2Array(face_uvs + face_uvs + face_uvs + face_uvs + face_uvs + face_uvs)

static func get_cube_uvs_from_verts(verts:Array, unit_size:float) -> PackedVector2Array:
	var u := unit_size

	var face_uvs := []

	for i in verts.size():
		var v = verts[i]

		if   i < 12: face_uvs.append(Vector2(v.z+u, -v.y+u))
		elif i < 24: face_uvs.append(Vector2(v.x+u, -v.y+u))
		else:        face_uvs.append(Vector2(v.x+u, v.z+u))

	return PackedVector2Array(face_uvs)


#               010           110                         Z
#   Vertices     A0 ---------- B1            Faces      Top    -Y
#           011 /  |      111 /  |                        |   North
#             E4 ---------- F5   |                        | /
#             |    |        |    |          -X West ----- 0 ----- East X
#             |   D3 -------|-- C2                      / |
#             |  /  000     |  / 100               South  |
#             H7 ---------- G6                      Y    Bottom
#              001           101                          -Z


static func get_cube_uvs_from_quads(quads:Array[Array], unit_size:float) -> PackedVector2Array:
	var u := unit_size

	var face_uvs := []

	for q in quads:
		var n = Plane(q[0], q[1], q[2]).normal
		var uvs = []
		match n:
			Vector3.LEFT, Vector3.RIGHT:         #west, east
				for v in q:
					uvs.append(Vector2(v.z+u, -v.y+u))
			Vector3.FORWARD, Vector3.BACK:       # north, south
				for v in q:
					uvs.append(Vector2(v.x+u, -v.y+u))
			Vector3.UP, Vector3.DOWN:            # top, bottom
				for v in q:
					uvs.append(Vector2(v.x+u, v.z+u))

		face_uvs += [uvs[0], uvs[1], uvs[2], uvs[0], uvs[2], uvs[3]]

	return PackedVector2Array(face_uvs)

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#			Mesh building functions

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
static func build_mesh_3d(mesh_info:Array[Dictionary]) -> ArrayMesh:
	var mesh = ArrayMesh.new()

	for idx in mesh_info.size():
		var surface_info:Dictionary = mesh_info[idx]
		assert(surface_info.has("vertices"))
		surface_info.vertices = PackedVector3Array(surface_info.vertices)
		MeshUtils.build_mesh_surface(mesh, idx, surface_info)

	return mesh


static func build_mesh_2d(mesh_info:Array[Dictionary]) -> ArrayMesh:
	var mesh = ArrayMesh.new()

	for idx in mesh_info.size():
		var surface_info:Dictionary = mesh_info[idx]
		assert(surface_info.has("vertices"))
		surface_info.vertices = PackedVector2Array(surface_info.vertices)
		MeshUtils.build_mesh_surface(mesh, idx, surface_info)

	return mesh


static func build_mesh_surface(mesh:ArrayMesh, idx:int, surface_info:Dictionary) -> void:
	assert(surface_info.has("primitive_type"))

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)

	arrays[Mesh.ARRAY_VERTEX] = surface_info.vertices
	if surface_info.has("indices"):  arrays[Mesh.ARRAY_INDEX]  = PackedInt32Array(surface_info.indices)
	if surface_info.has("normals"):  arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array(surface_info.normals)
	if surface_info.has("uvs"):      arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array(surface_info.uvs)
	if surface_info.has("colors"):   arrays[Mesh.ARRAY_COLOR]  = PackedColorArray(surface_info.colors)
	if surface_info.has("tangents"): arrays[Mesh.ARRAY_TANGENT] = PackedFloat32Array(surface_info.tangents)
	if surface_info.has("uv2s"):     arrays[Mesh.ARRAY_TEX_UV2] = PackedVector2Array(surface_info.uv2s)
	if surface_info.has("bones"):    arrays[Mesh.ARRAY_BONES] = PackedFloat32Array(surface_info.bones)
	if surface_info.has("weights"):  arrays[Mesh.ARRAY_WEIGHTS] = PackedFloat32Array(surface_info.weights)

	mesh.add_surface_from_arrays(surface_info.primitive_type, arrays)
	if surface_info.has("material"):
		mesh.surface_set_material(idx, surface_info.material)


static func build_mesh(mesh_info:Array) -> ArrayMesh:
	var mesh = ArrayMesh.new()

	for idx in mesh_info.size():
		var surface_info:Dictionary = mesh_info[idx]
		assert(surface_info.has("vertices"))
		assert(surface_info.has("primitive_type"))

		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)

		arrays[Mesh.ARRAY_VERTEX] = surface_info.vertices
		if surface_info.has("indices"):  arrays[Mesh.ARRAY_INDEX]   = surface_info.indices
		if surface_info.has("normals"):  arrays[Mesh.ARRAY_NORMAL]  = surface_info.normals
		if surface_info.has("uvs"):      arrays[Mesh.ARRAY_TEX_UV]  = surface_info.uvs
		if surface_info.has("colors"):   arrays[Mesh.ARRAY_COLOR]   = surface_info.colors
		if surface_info.has("tangents"): arrays[Mesh.ARRAY_TANGENT] = surface_info.tangents
		if surface_info.has("uv2s"):     arrays[Mesh.ARRAY_TEX_UV2] = surface_info.uv2s
		if surface_info.has("bones"):    arrays[Mesh.ARRAY_BONES]   = surface_info.bones
		if surface_info.has("weights"):  arrays[Mesh.ARRAY_WEIGHTS] = surface_info.weights

		mesh.add_surface_from_arrays(surface_info.primitive_type, arrays)
		if surface_info.has("material"):
			mesh.surface_set_material(idx, surface_info.material)

	return mesh




#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#			Mouse interaction functions

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
static func is_mouse_in_poly_2d(mouse_pos:Vector2, poly_verts:Array) -> bool:
	return Geometry2D.is_point_in_polygon(mouse_pos, poly_verts)


static func unproject_verts(verts:Array, camera:Camera3D) -> Array:
	var unpj_verts := []
	for v in verts:
		unpj_verts.append(camera.unproject_position(v))
	return unpj_verts


# 'faces' is a 2D array of Vector3
static func unproject_faces(faces:Array, camera:Camera3D) -> Array:
	var unpj_faces := []
	for f in faces:
		unpj_faces.append(unproject_verts(f, camera))
	return unpj_faces


#static func unproject_quad_centers(faces:Array, camera:Camera3D) -> Array:
#	var unpj_centers := []
#	for f in faces:
#		unpj_centers.append(camera.unproject_position( (f[0]+f[2])/2.0) )
#	return unpj_centers


# quads = 2D array of Vector3
static func get_quad_closest_to_mouse(quads:Array, mouse_pos:Vector2, camera:Camera3D, must_be_hovered:=true):
	var closest_face = -1
	var closest_dist = 99999999

	for i in quads.size():
		var unpj_verts := unproject_verts(quads[i], camera)

		if must_be_hovered \
		and !is_mouse_in_poly_2d(mouse_pos, unpj_verts):
			continue

		var center:Vector2 = (unpj_verts[0]+unpj_verts[2])/2.0
		var dist := mouse_pos.distance_to(center)

		if dist < closest_dist:
			closest_dist = dist
			closest_face = i

	return closest_face






