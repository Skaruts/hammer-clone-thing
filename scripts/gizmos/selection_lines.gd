class_name SelectionLines extends Node3D

var _backlines:DrawTool3DMesh
var _forelines:DrawTool3DMesh

var back_color:Color:
	get: return _backlines.line_color
	set(color): _backlines.line_color = color

var fore_color:Color:
	get: return _forelines.line_color
	set(color): _forelines.line_color = color

func _init(_fore_color:Color, _back_color:Color) -> void:
	_backlines = DrawTool3DMesh.new()
	_backlines.on_top = true
#	_backlines.render_priority = -1
	_backlines.transparent = true
	_backlines.single_color = true
#	_backlines.line_color = back_color
	back_color = _back_color
	_backlines.line_thickness = 2
	add_child(_backlines)

	_forelines = DrawTool3DMesh.new()
	_forelines.on_top = false
#	_forelines.unshaded = false
	_forelines.transparent = true
	_forelines.single_color = true
#	_forelines.line_color = fore_color
	fore_color = _fore_color
	_forelines.line_thickness = 4
	add_child(_forelines)


func draw(edges:Array[Edge]) -> void:
	for e in edges:
		var a := BrushUtils.gu_to_eu(e.v1.vec)
		var b := BrushUtils.gu_to_eu(e.v2.vec)
		_forelines.line(a, b)
		_backlines.line(a, b)


func clear() -> void:
	_forelines.clear()
	_backlines.clear()
