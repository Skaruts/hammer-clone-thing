class_name BoundingBox extends Node3D

var p1:Vector3
var p2:Vector3

#var _backlines:DrawTool3DMesh
var _forelines:DrawTool3DMesh
var _face_alpha := 0.25

#var fore_color:Color:
#	get: return _forelines.line_color
#	set(color):
#		_forelines.line_color = color
##		_backlines.line_color = Color(color.darkened(0.25), 0.25)



func _init(color:Color) -> void:
#	_backlines = DrawTool3DMesh.new()
#	_backlines.on_top = true
#	_backlines.render_priority = -1
#	_backlines.transparent = true
##	_backlines.single_color = true
##	_backlines.line_color = back_color
#	_backlines.line_color = Color(color.darkened(0.25), 0.25)
#	_backlines.line_thickness = 4
#	add_child(_backlines)

	_forelines = DrawTool3DMesh.new()
	_forelines.see_through = true
	_forelines.double_sided = true
#	_forelines.on_top = false
#	_forelines.unshaded = false
#	_forelines.transparent = true
#	_forelines.single_color = true
	_forelines.line_color = color
#	fore_color = color
	_forelines.line_thickness = 4
	add_child(_forelines)


func draw(_p1:Vector3, _p2:Vector3) -> void:
	p1 = _p1
	p2 = _p2

#	_backlines.cube_lines(p1, p2)
#	_backlines.cube_faces(p1, p2, Color(_backlines.line_color, _face_alpha))
	_forelines.cube_lines(p1, p2)
	_forelines.cube_faces(p1, p2, Color(_forelines.line_color, _face_alpha))


func get_edges() -> Array:
	return MeshUtils.get_cube_edges_from_points(p1, p2)

func clear() -> void:
#	_backlines.clear()
	_forelines.clear()
