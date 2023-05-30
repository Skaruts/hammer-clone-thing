#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
# 	3D Grid Plane Helper  (0.1)
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
extends Node3D


var grid_size   :int = 64  # size of the grid (MUST BE EVEN)
var origin_size :int = 3   # size of the origin axes lines
var xz_steps    :int = 8   # how many lines to skip between axis grid lines

# Todo these colors might be better in EditorData
# so the user can customize them
var color_x_axis := Color.RED  # origin axes colors
var color_y_axis := Color.GREEN
var color_z_axis := Color.BLUE

var color_grid_lines  := Color("303030")  # grid color
var color_x_grid_line := Color("400000")  # color of the x axis lines
var color_z_grid_line := Color("004000")  # color of the z axis lines
var color_bounds      := Color.BLUE       # color of the grid bounds

var _origin:Node3D
var _grid:Node3D

var _origin_mat_flags:int = MeshUtils.MAT_UNSHADED #| MeshUtils.MAT_ON_TOP
var _grid_mat_flags:int   = MeshUtils.MAT_UNSHADED


func _ready() -> void:
	_origin = Node3D.new()
	_grid  = Node3D.new()
	add_child(_origin)
	add_child(_grid)
	_origin.name = "Origin"
	_grid.name = "Grids"
	build()

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#        Public interface

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
func build() -> void:
#	_create_grid_bounds()
#	_create_grid()
	_create_origin()


func is_origin_visible() -> bool:  return _origin.visible
func hide_origin() -> void:        _origin.visible = false
func show_origin() -> void:        _origin.visible = true
func toggle_origin() -> void:      hide_origin() if _origin.visible else show_origin()

func is_grid_visible() -> bool:  return _grid.visible
func hide_grid() -> void:        _grid.visible = false
func show_grid() -> void:        _grid.visible = true
func toggle_grid() -> void:      hide_grid() if _grid.visible else show_grid()



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#        Internal stuff

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
func _make_material(thickness:=1, flags:=0) -> StandardMaterial3D:
	var mat:StandardMaterial3D = MeshUtils.new_color_material(Color.WHITE, thickness, flags)
	mat.vertex_color_use_as_albedo = true
	return mat


func _make_mesh(parent:Node3D, vertices:Array, colors:Array, material:StandardMaterial3D) -> void:
	var m:ArrayMesh = MeshUtils.build_mesh([{
		primitive_type = Mesh.PRIMITIVE_LINES,
		vertices = vertices,
		colors = colors,
	}])

	var mi := MeshInstance3D.new()
	mi.mesh = m
	mi.material_override = material
	parent.add_child(mi)


func _create_grid() -> void:
	var vertices := []
	var colors := []

	@warning_ignore("integer_division")
	var hgs:int = grid_size/2

	for i in range(-hgs, hgs):
		vertices += [
			Vector3( -hgs, 0,    i),
			Vector3(  hgs, 0,    i),
			Vector3(    i, 0, -hgs),
			Vector3(    i, 0,  hgs)
		]

		if i % xz_steps != 0:
			colors += [color_grid_lines, color_grid_lines, color_grid_lines, color_grid_lines]
		else:
			colors += [color_x_grid_line, color_x_grid_line, color_z_grid_line, color_z_grid_line]

	_make_mesh(_grid, vertices, colors,	_make_material(1, _grid_mat_flags))


func _create_grid_bounds() -> void:
	@warning_ignore("integer_division")
	var hgs:int = grid_size/2

	var a := Vector3(-hgs, 0, -hgs)
	var b := Vector3( hgs, 0, -hgs)
	var c := Vector3( hgs, 0,  hgs)
	var d := Vector3(-hgs, 0,  hgs)

	var vertices := [a,b, b,c, c,d, d,a]
	var colors := [	color_bounds, color_bounds, color_bounds, color_bounds,
					color_bounds, color_bounds, color_bounds, color_bounds	]

	_make_mesh(_grid, vertices, colors, _make_material(1, _grid_mat_flags))


func _create_origin() -> void:
#	var gc := Vector3( grid_size/2.0, 0, grid_size/2.0 ) # grid center
	var os := 10000 #origin_size

	# TODO: this could be a single mesh with two surfaces (same for grids, btw)

	var m:ArrayMesh = MeshUtils.build_mesh_3d([{
			primitive_type = Mesh.PRIMITIVE_LINES,
			vertices = [
				Vector3.ZERO, Vector3( os,  0,  0 ),
				Vector3.ZERO, Vector3(  0, os,  0 ),
				Vector3.ZERO, Vector3(  0,  0, os ),
			],
			colors = [
				color_x_axis,	color_x_axis,
				color_y_axis,	color_y_axis,
				color_z_axis,	color_z_axis,
			],
		},
		{
			primitive_type = Mesh.PRIMITIVE_LINES,
			vertices = [
				Vector3( -os,   0,   0 ), Vector3.ZERO,
				Vector3(   0, -os,   0 ), Vector3.ZERO,
				Vector3(   0,   0, -os ), Vector3.ZERO,
			],
			colors = [
				color_x_axis.darkened(0.8),	color_x_axis.darkened(0.8),
				color_y_axis.darkened(0.8),	color_y_axis.darkened(0.8),
				color_z_axis.darkened(0.8),	color_z_axis.darkened(0.8),
			],
#			colors = [
#				color_x_axis,	color_x_axis,
#				color_y_axis,	color_y_axis,
#				color_z_axis,	color_z_axis,
#			],
		},
	])

	var mi := MeshInstance3D.new()
	mi.mesh = m
	mi.material_override = _make_material(2, _origin_mat_flags)
	_origin.add_child(mi)

#	_make_mesh(_origin, vertices, colors, _make_material(2, _origin_mat_flags))


#	_make_mesh(_origin, vertices, colors, _make_material(2, _origin_mat_flags))

