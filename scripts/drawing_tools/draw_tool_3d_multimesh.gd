class_name DrawTool3DMesh extends Node3D

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#        DrawTool3DMesh 0.9.8 (Godot 4)
#
#    Does 3D drawing using MultiMeshes for lines, cones, sphere, and cubes.
#    Uses an ImmediateMesh to draw faces, since they don't require a thickness.
#    Uses Label3D for text (may use TextMeshes in the future - need testing).
#
#
#    This uses a MultiMeshInstance to draw instances of a cube or cylinder,
#    stretched to represent lines, and spheres for 3D points.
#    For each line AB, scales an instance of a cube in one axis to equal the
#    distance from A to B, and then rotates it accordingly using
#     'transform.looking_at()'.
#    Cylinders, however, are upright by default, along the Y axis, so they
#    have to be manually rotated to compensate for this. Their code
#    isn't working properly in Godot 4, though.
#
#
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
# TODO:
#   - consider periodically lowering the 'instance_count', since currently it
#     grows as needed, and stays as is to serve as an object pool,
#     but it never comes back down (not sure it's really an issue)
#
#   - draw quads
#   - draw polygons
#
#   - create cylinders without caps through code (and cones) ?

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

# 		Internal settings

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
## how many instances to add when more instances are needed
const _INSTANCE_INCREMENT = 16

## how thin must the unit-cube be in order to properly represent a line
## of thickness 1. Must be tweaked according to the intended usage (i.e., lines
## that are seen from very up close may look too thick).
const _WIDTH_FACTOR = 0.005

const _RADIAL_SEGMENTS = 8
const _SPHERE_RINGS = 4
const _CIRCLE_SEGMENTS = 16



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

# 		User settings (change before adding as child)

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
var single_color := false

var line_color := Color.WHITE
var backline_color:Color
var face_color:Color
var backface_color:Color

var line_thickness := 1.0
var unshaded := true    # actually looks great shaded, except for the cylinder caps
var on_top := true
var no_shadows := true
#var render_priority := 0
var transparent := false
var double_sided := false

var back_alpha := 0.5
var face_alpha := 0.5
var darken_factor := 0.25
var see_through := false  # TODO: rename this



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#    Public API

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
func clear() -> void:
	# keep the real 'instance_count' up, to serve as a pool
	for mm in _mms.values():
		mm.visible_instance_count = 0
	_clear_labels()
	_im.clear_surfaces()

enum {A,B,C,D,E,F,G,H}
func draw_quad(verts:Array[Vector3], color:=face_color) -> void:
	_im.surface_begin(Mesh.PRIMITIVE_TRIANGLES)#, _im_fore_mat)

	var tri_verts := [verts[A],verts[B],verts[C],verts[A],verts[C],verts[D]]

	for v in tri_verts:
		_im.surface_set_color(color)
		_im.surface_add_vertex(v)

	_im.surface_end()



func line(a:Vector3, b:Vector3, color:=line_color, thickness:=line_thickness) -> void:
	_add_line(a, b, color, thickness)

# points = contiguous Array[Vector3]
func polyline(points:Array, color:=line_color, thickness:=line_thickness) -> void:
	for i in range(1, points.size(), 1):
		_add_line(points[i-1], points[i], color, thickness)

# lines = array of arrays: [a, b, color, thickness]
func bulk_lines(lines:Array) -> void:
	for l in lines:
		_add_line(l[0], l[1], l[2], l[3])


func dashed_line(a:Vector3, b:Vector3, colors:=[], thickness:=line_thickness) -> void:
	var c1:Color = line_color if colors.size() < 1 else colors[0]
	var c2:Color = Color.TRANSPARENT if colors.size() < 2 else colors[1]

	# TODO: how do I divide the line
	#       the docs for CanvasItem.draw_dashed_line isn't elucidating

	pass

enum {
	WIRE         = 1,
	FACES        = 2,
	ALL          = 3,
}

#func cube(p1:Vector3, p2:Vector3, flags:=ALL) -> void:
#	if flags & WIRE:  cube_lines(p1, p2, line_color, line_thickness)
#	if flags & FACES: cube_faces(p1, p2, line_color)


func cube_faces(p1:Vector3, p2:Vector3, color:=line_color) -> void:
#	var pos := Vector3(min(p1.x, p2.x), min(p1.y, p2.y), min(p1.z, p2.z))
	var pos := (p1 + p2) / 2
	var size := Vector3(p2.x-p1.x, p2.y-p1.y, p2.z-p1.z).abs()
	_add_cube(pos, size, color)


func cube_lines(p1:Vector3, p2:Vector3, color:=line_color, thickness:=line_thickness) -> void:
	var a := Vector3( p1.x, p2.y, p1.z )
	var b := Vector3( p2.x, p2.y, p1.z )
	var c := Vector3( p2.x, p1.y, p1.z )
	var d := p1
	var e := Vector3( p1.x, p2.y, p2.z )
	var f := p2
	var g := Vector3( p2.x, p1.y, p2.z )
	var h := Vector3( p1.x, p1.y, p2.z )

	var pl1 := [a,b,c,d,a]
	var pl2 := [e,f,g,h,e]

	polyline(pl1, color, thickness)
	polyline(pl2, color, thickness)
	_add_line(a, e, color, thickness)
	_add_line(b, f, color, thickness)
	_add_line(c, g, color, thickness)
	_add_line(d, h, color, thickness)




# useful for drawing vectors as arrows, for example
func cone(position:Vector3, direction:Vector3, color:Color, thickness:=1.0) -> void:
	_add_cone(position, direction, color, thickness)

# cones = array of arrays: [position, direction, color, thickness]
func bulk_cones(cones:Array) -> void:
	for c in cones:
#		var tip = c[0]+c[1]
		if c.size() > 3:
			_add_cone(c[0], c[1], c[2], c[3])
		else:
			_add_cone(c[0], c[1], c[2])


func point(position:Vector3, color:Color, size:=1.0) -> void:
	_add_sphere(position, color, size)

# points = contiguous Array[Vector3]
func points(points:Array, color:Color, size:=1.0) -> void:
	for p in points:
		_add_sphere(p, color, size)

# points = array of arrays: [position, color, size]
func bulk_points(points:Array) -> void:
	for p in points:
		if p.size() > 2: _add_sphere(p[0], p[1], p[2])
		else:            _add_sphere(p[0], p[1])


func circle(position:Vector3, radius:float, axis:Vector3, color:Color, thickness:=1.0):
	var points := _create_circle_points(position, radius, axis, color)
	points.append(points[0])
	polyline(points, color, thickness)


func bulk_circles(circles:Array) -> void:
	for c in circles:
		circle(c[0], c[1], c[2], c[3], c[4])






func text(position:Vector3, string:String, color:Color, size:=1.0) -> void:
	_add_label(position, string, color, size)

func bulk_text(labels:Array) -> void:
	for c in labels:
		_add_label(c[0], c[1], c[2], c[3])





#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#    initialization

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
const _DOT_THRESHOLD = 0.999

var _mms:Dictionary # MultiMeshes
var _im:ImmediateMesh

var _use_cylinders_for_lines := false  # cylinders not working in Godot 4

var _labels := []
var _label_nodes:Node3D
var _num_labels := 0
var _num_visible_labels := 0

var _base_mat:StandardMaterial3D
var _fore_mat:StandardMaterial3D
var _im_base_mat:StandardMaterial3D
var _im_fore_mat:StandardMaterial3D


func _init(_name=null) -> void:
	name = "DrawTool3DMesh" if not _name else _name
#	_create_materials()


func _ready() -> void:
	backline_color = Color(line_color.darkened(darken_factor), back_alpha)
	face_color     = Color(line_color, face_alpha)
	backface_color = Color(face_color.darkened(darken_factor), back_alpha)

	_label_nodes = Node3D.new()
	add_child(_label_nodes)
	_label_nodes.name = "3d_labels"

	_init_im()
	_init_mmis()




func _init_im() -> void:
	if not see_through:
		_im_base_mat = _create_material(face_color)
		_im_base_mat.cull_mode = BaseMaterial3D.CULL_DISABLED if double_sided else BaseMaterial3D.CULL_BACK
	else:
		_im_fore_mat = _create_material(face_color)
		_im_fore_mat.cull_mode = BaseMaterial3D.CULL_DISABLED if double_sided else BaseMaterial3D.CULL_BACK
		_im_fore_mat.no_depth_test = false

		_im_base_mat = _create_material(backface_color)
		_im_base_mat.cull_mode = BaseMaterial3D.CULL_DISABLED if double_sided else BaseMaterial3D.CULL_BACK
		_im_base_mat.render_priority = -1
		_im_base_mat.next_pass = _im_fore_mat
		_im_base_mat.no_depth_test = true


	_im = ImmediateMesh.new()
	var mi := MeshInstance3D.new()
	mi.mesh = _im
	add_child(mi)

	mi.material_override = _im_base_mat


func _init_mmis() -> void:
	if not see_through:
		_base_mat = _create_material(line_color)
	else:
		_fore_mat = _create_material(line_color)
		_fore_mat.no_depth_test = false

		_base_mat = _create_material(backline_color)
		_base_mat.render_priority = -1
		_base_mat.next_pass = _fore_mat
		_base_mat.no_depth_test = true

#	if _use_cylinders_for_lines:
	_mms["cylinder_lines"] = _init_line_mesh__cylinder(_base_mat)
#	else:
	_mms["cube_lines"] = _init_line_mesh__cube(_base_mat)

	_mms["cones"]   = _init_cone_mesh(_base_mat)
	_mms["spheres"] = _init_sphere_mesh(_base_mat)
	_mms["cubes"]   = _init_cube_mesh(_base_mat)

	# TODO: textmeshes will require some work to support outlines
#	_mms["texts"]   = _init_text_mesh(_base_mat)

func _create_material(color:Color) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.vertex_color_use_as_albedo = not single_color
	mat.no_depth_test = on_top
	mat.disable_receive_shadows = no_shadows
#	mat.render_priority = render_priority

	if unshaded:    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	else:           mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	if transparent or see_through: mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	else:                          mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED

	return mat


func _init_line_mesh__cylinder(mat:StandardMaterial3D) -> MultiMesh:
	# ----------------------------------------
	# create lines

	# Note: cylinders look like the cubes with 4 radial_segments
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = _WIDTH_FACTOR
	cylinder.bottom_radius = _WIDTH_FACTOR
	cylinder.height = 1
	cylinder.radial_segments = _RADIAL_SEGMENTS
	cylinder.rings = 0
	cylinder.material = mat

	return _create_multimesh(cylinder)


func _init_line_mesh__cube(mat:StandardMaterial3D) -> MultiMesh:
	var cube := BoxMesh.new()
	cube.size = Vector3(_WIDTH_FACTOR, _WIDTH_FACTOR, 1)
	cube.material = mat

	return _create_multimesh(cube)


func _init_cube_mesh(mat:StandardMaterial3D) -> MultiMesh:
	var box_mesh := BoxMesh.new()
	box_mesh.material = mat
	return _create_multimesh(box_mesh)


#func _init_text_mesh(mat:StandardMaterial3D) -> MultiMesh:
#	var text_mesh := TextMesh.new()
#	text_mesh.material = mat
#
#	return _create_multimesh(text_mesh)


func _init_cone_mesh(mat:StandardMaterial3D) -> MultiMesh:
	# ----------------------------------------
	# create cones (for vectors)
	var cone := CylinderMesh.new()
	cone.top_radius = 0
	cone.bottom_radius = _WIDTH_FACTOR*4
	cone.height = 0.04
	cone.radial_segments = _RADIAL_SEGMENTS
	cone.rings = 0
	cone.material = mat

	return _create_multimesh(cone)


func _init_sphere_mesh(mat:StandardMaterial3D) -> MultiMesh:
	# ----------------------------------------
	# create spheres
	var sphere := SphereMesh.new()
	sphere.radius = _WIDTH_FACTOR
	sphere.height = _WIDTH_FACTOR*2
	sphere.radial_segments = _RADIAL_SEGMENTS
	sphere.rings = _SPHERE_RINGS
	sphere.material = mat

	return _create_multimesh(sphere)


#func _create_materials() -> void:
#	_mat1 = StandardMaterial3D.new()
##	_mat1.vertex_color_use_as_albedo = true
#	_mat1.flags_unshaded = true
#	_mat1.no_depth_test = true
#	_mat1.disable_receive_shadows = true
#	_mat1.flags_transparent = true
#	_mat1.albedo_color = Color(1,1,1,0.25)
#	_mat1.render_priority = -1
#
#	_mat2 = StandardMaterial3D.new()
#	_mat2.vertex_color_use_as_albedo = true
#	_mat2.flags_unshaded = unshaded
#	_mat2.no_depth_test = false
#	_mat2.disable_receive_shadows = true
#	_mat2.flags_transparent = true
#	_mat2.albedo_color = Color.WHITE
##
#	_mat1.next_pass = _mat2
#	_mat2.next_pass = _mat2


#func _create_materials():
#	_mat1 = StandardMaterial3D.new()
#	_mat1.vertex_color_use_as_albedo = true
#	_mat1.flags_unshaded = unshaded
#	_mat1.no_depth_test = true
#	_mat1.disable_receive_shadows = true
#	_mat1.flags_transparent = _USE_TRANSPARENCY
#	_mat1.albedo_color = Color(1,1,1, _MAX_ALPHA) if _USE_TRANSPARENCY else Color.WHITE
#
##	if outlines:
##		var np_mat := StandardMaterial3D.new()
##		np_mat.flags_unshaded = unshaded
##		np_mat.disable_receive_shadows = true
##		np_mat.no_depth_test = true
##		np_mat.albedo_color = Color.BLACK
##		np_mat.params_grow = true
##		np_mat.params_grow_amount = 0.005
##		np_mat.render_priority = -1
##
##		_mat1.next_pass = np_mat



#var shaded:BaseMaterial3D.ShadingMode:
##	get: return _mat1.flags_unshaded
##	set(enabled): _mat1.flags_unshaded = enabled
#	get: return _mat1.shading_mode
#	set(mode): _mat1.shading_mode = mode
#
#var on_top:bool:
#	get: return _mat2.no_depth_test
#	set(enabled): _mat2.no_depth_test = enabled


func _create_multimesh(mesh:Mesh) -> MultiMesh:
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
#	mm.color_format = MultiMesh.COLOR_FLOAT
	mm.use_colors = true
	mm.mesh = mesh
	mm.visible_instance_count = 0
	mm.instance_count = _INSTANCE_INCREMENT

	var mmi = MultiMeshInstance3D.new()
	mmi.multimesh = mm
	add_child(mmi)
	return mm



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#    internal API

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
var _cross_axis := Vector3.RIGHT
func _create_circle_points(position:Vector3, radius:float, axis:Vector3, _color:Color) -> Array:
	axis = axis.normalized()

	# TODO: when the axis used in the cross product below is the same
	# as the circle's axis, use a perpendicular axis instead
	if axis == _cross_axis:
		if _cross_axis == Vector3.RIGHT:
			_cross_axis = Vector3.UP
		elif _cross_axis == Vector3.UP:
			_cross_axis = Vector3.RIGHT

	var points := []
	var cross = axis.cross(_cross_axis).normalized() *  radius

	# this was intended for some edge cases, but it seems like it never happens
	var dot = abs(cross.dot(axis))
	if dot > 0.9:
		print("THIS CODE IS RUNNING!!!!!") # seems like this code never runs
		cross = axis.cross(Vector3.UP) * radius

#	print(axis, cross, dot)

	# draw a debug cross-product vector
#	line(position, position+cross, _color, 2)
#	cone(position+cross, cross, _color, 2)

	for r in range(0, 360, 360/float(_CIRCLE_SEGMENTS)):
		var c = cross.rotated(axis, deg_to_rad(r))
		var p = position + c * radius
#		printt(p, c, c * radius)
		points.append(p)
#		point(p, Color.yellow, 5) # draw debug point

	return points


func _create_circle_points_OLD(position:Vector3, radius:Vector3, axis:Vector3) -> Array:
	var points := []

	for r in range(0, 360, 360/float(_RADIAL_SEGMENTS)):
		var p = position + radius.rotated(axis, deg_to_rad(r))
		points.append(p)

	return points

# http://kidscancode.org/godot_recipes/3.x/3d/3d_align_surface/
func align_with_y(tr:Transform3D, new_y:Vector3) -> Transform3D:
	if new_y.dot(Vector3.FORWARD) in [-1, 1]:
#		new_y = Vector3.RIGHT
		tr.basis.y = new_y
		tr.basis.z = tr.basis.x.cross(new_y)
		tr.basis = tr.basis.orthonormalized()
	else:
		printt("dot: ", new_y.dot(Vector3.FORWARD), new_y)

		tr.basis.y = new_y
		tr.basis.x = -tr.basis.z.cross(new_y)
		tr.basis = tr.basis.orthonormalized()
	return tr


#TODO: Test if it's really better to add many instances once in a while
#      versus adding one instance every time it's needed.
#      Maybe there's a tradeoff between too many and too few.
func _add_instance_to(mm:MultiMesh) -> int:
	# the index of a new instance is count-1
	var idx := mm.visible_instance_count
	mm.visible_instance_count += 1

	# if the visible count reaches the instance count, then more instances are needed
	if mm.instance_count <= mm.visible_instance_count:
		# this is enough to make the MultiMesh create more instances internally
		mm.instance_count += _INSTANCE_INCREMENT

	return idx


func _commit_instance(mm:MultiMesh, idx:int, transform:Transform3D, color:Color) -> void:
	mm.set_instance_transform(idx, transform)
	# TODO: check what to do about this when using 'single_color'
	mm.set_instance_color(idx, color)



func _add_line(a:Vector3, b:Vector3, color:=line_color, thickness:=line_thickness) -> void:
	if _use_cylinders_for_lines:
		_add_line_cylinder(a, b, color, thickness)
	else:
		_add_line_cube(a, b, color, thickness)




func _check_equal_points(a:Vector3, b:Vector3) -> bool:
	if a != b: return false
#	push_warning("points 'a' and 'b' are the same: %s == %s" % [a, b])
	return true


func _add_line_cube(a:Vector3, b:Vector3, color:Color, thickness:=1.0) -> void:
	# I had issues here with 'looking_at', which I can't quite remember,
	# but I solved somehow. I posted it here:
	#     https://godotforums.org/d/27860-transform-looking-at-not-working
	# I found a potentially better solution instead of 'looking_at', used
	# below, in the cylinder line function

	var mm:MultiMesh = _mms["cube_lines"]
	if _check_equal_points(a, b): return

	# adding an instance is basically just raising the visible_intance_count
	# and then using that index to get and set properties of the instance
	var idx := _add_instance_to(mm)

	# if transform is to be orthonormalized, do it here beback applying any
	# scaling, or it will revert the scaling
	var transform := Transform3D() # mm.get_instance_transform(idx).orthonormalized()
#	var transform := Transform()
	transform.origin = (a+b)/2

	var target_direction := (b-transform.origin).normalized()
	transform = transform.looking_at(b,
		Vector3.UP if abs(target_direction.dot(Vector3.UP)) < _DOT_THRESHOLD
		else Vector3.BACK
	)

	# TODO: this probably accumulates scaling if this instance was scaled beback,
	#       but I've never seen any issues, so... I could be wrong.
	transform.basis.x *= thickness
	transform.basis.y *= thickness
	transform.basis.z *= a.distance_to(b) + _WIDTH_FACTOR * thickness

	_commit_instance(mm, idx, transform, color)


func _add_line_cylinder(a:Vector3, b:Vector3, color:Color, thickness:=1.0) -> void:
	if _check_equal_points(a, b): return

	var mm:MultiMesh = _mms["cylinder_lines"]
	var idx := _add_instance_to(mm)

	var transform := Transform3D() # mm.get_instance_transform(idx).orthonormalized()
	transform.origin = (a+b)/2

	var target_direction := (b-transform.origin).normalized()

	transform = align_with_y(transform, target_direction)


	#	printt("target_direction", target_direction, b)
#	transform = transform.looking_at(b,
#		Vector3.BACK if abs(target_direction.dot(Vector3.FORWARD)) < _DOT_THRESHOLD
#		else Vector3.UP
#	)

	#	var dot = abs(target_direction.dot(axis))
	#	if dot > 0.9:
	#		print("I WAS HERE") # this seems to never run
	#		cross = axis.cross(Vector3.UP) * radius


	transform.basis.x *= thickness
	transform.basis.y *= a.distance_to(b) # + _WIDTH_FACTOR * thickness # stretch the Y instead
	transform.basis.z *= thickness

	_commit_instance(mm, idx, transform, color)


func _add_cone(position:Vector3, direction:Vector3, color:Color, thickness:=1.0):
	var mm:MultiMesh = _mms["cones"]

	var idx := _add_instance_to(mm)
	var transform := Transform3D()
	transform.origin = position

	transform = align_with_y(transform, direction)

	transform.basis = transform.basis.scaled(Vector3.ONE * thickness)

	_commit_instance(mm, idx, transform, color)


func _add_sphere(position:Vector3, color:Color, size:=1.0) -> void:
	var mm:MultiMesh = _mms["spheres"]

	var idx := _add_instance_to(mm)
#	var transform := mm.get_instance_transform(idx).orthonormalized()
	var transform := Transform3D()

	transform.origin = position
	transform.basis = transform.basis.scaled(Vector3.ONE * size)

	_commit_instance(mm, idx, transform, color)


func _add_cube(position:Vector3, size:Vector3, color:Color) -> void:
	var mm:MultiMesh = _mms["cubes"]
	var idx := _add_instance_to(mm)

	var transform := Transform3D() # mm.get_instance_transform(idx).orthonormalized()
	transform.origin = position
	transform.basis.x *= size
	transform.basis.y *= size
	transform.basis.z *= size

	_commit_instance(mm, idx, transform, color)


func _create_new_label() -> Label3D:
	var l := Label3D.new()
	_label_nodes.add_child(l)
	_labels.append(l)
	_num_labels += 1

#	l.fixed_size = true
	l.shaded = false
	l.double_sided = false
	l.no_depth_test = true
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	return l


func _clear_labels() -> void:
	for l in _labels:
		l.visible = false
	_num_visible_labels = 0

# using a similar system to the MultiMeshInstance
func _add_label(position:Vector3, string:String, color:Color, size:=1.0) -> void:
	var l:Label3D
	_num_visible_labels += 1

	if _num_labels < _num_visible_labels:
		l = _create_new_label()
	else:
		l = _labels[_num_visible_labels-1]
		l.visible = true

	l.position = position
	l.text = string
	l.modulate = color
	l.scale = Vector3.ONE * size



