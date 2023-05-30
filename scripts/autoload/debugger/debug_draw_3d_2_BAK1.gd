extends Spatial

onready var _debugger:CanvasLayer = get_parent()
onready var dt := DrawTool3DMesh.new()


var active := true
var _curr_line_color = Color.white

var _tracking_commands := {}


var _lines := []
var _points := []
var _cones := []
var _circles := []


func _ready() -> void:
	add_child(dt)
	pass



func _redraw() -> void:
	dt.clear()

	dt.bulk_lines(_lines)
	dt.bulk_points(_points)
	dt.bulk_cones(_cones)
	dt.bulk_circles(_circles)

	_lines.clear()
	_points.clear()
	_cones.clear()
	_circles.clear()


func _process(delta: float) -> void:
	if not _debugger._debugging or not active: return
	_process_tracking_commands()
	_redraw()




#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#		public 3D drawing API
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
const __DEF_ID = "__debug_default_id__"

#func _add_command_dict(id, dict):
#	_persistent_commands[id] = dict

#func draw_line(id, start, end, color) -> void:
#	if not _debugger._debugging or not active: return
#	if id is String: _add_command_dict(id,     _build_line_dict(start, end, color))
#	else:            _add_command_dict(_next_id(), _build_line_dict(id, start, end))

var _curr_id := -1
func _next_id() -> String:
	_curr_id += 1
	return __DEF_ID + str(_curr_id)


var _draw_commands := []
# KEEP THESE PARAMETERS TYPELESS, THEY CAN BE STRINGS FOR TRACKING PROPERTIES
func _build_line_dict(start, end, color:Color, thickness:=1.0) -> Dictionary:
	return {type = "line", start = start, end = end, color = color, thickness = thickness}

func draw_line(start, end, color:Color, thickness:float) -> void:
	if not _debugger._debugging or not active: return
	_schedule_draw("line", [start, end, color, thickness])


# KEEP THESE PARAMETERS TYPELESS, THEY CAN BE STRINGS FOR TRACKING PROPERTIES
func _build_vector_dict(position, direction, color:Color, thickness:=1.0) -> Dictionary:
	return {type = "vector", position = position, direction = direction, color = color, thickness=thickness}

func draw_vector(position, direction, color:Color, thickness=1.0) -> void:
	if not _debugger._debugging or not active: return
	_schedule_draw("vector", [position, direction, color, thickness])


# KEEP THESE PARAMETERS TYPELESS, THEY CAN BE STRINGS FOR TRACKING PROPERTIES
func _build_point_dict(position, color:Color, size:=1.0) -> Dictionary:
	return {type="point", position=position, color=color, size=size}

func draw_point(position, color:Color, size:=1.0) -> void:
	if not _debugger._debugging or not active: return
	_schedule_draw("point", [position, color, size])


# KEEP THESE PARAMETERS TYPELESS
func _build_transform_dict(node:Spatial, transf_name:String, size:=1.0, thickness:=1.0) -> Dictionary:
#	print("%s | %s | %s | %s" % [node, transf_name, size, thickness])
	return {type = "transform", node=node, transf_name=transf_name, size=size, thickness=thickness}

func draw_transform(node:Spatial, transf_name:String, size:=1.0, thickness:=1.0) -> void:
	if not _debugger._debugging or not active: return
	# if id is String: _add_transform(id, node, size, thickness)
	# else:            _add_transform(_next_id(), id, node, size)
	_schedule_draw("transform", [node, transf_name, size, thickness])


func _build_circle_dict(position:Vector3, radius:float, axis:Vector3, color:Color, thickness:=1.0) -> Dictionary:
	return {type = "circle", position=position, radius=radius, axis=axis, color=color, thickness=thickness}

func draw_circle(position, axis, radius:float, color:Color, thickness:float) -> void:
	if not _debugger._debugging or not active: return
	_schedule_draw("circle", [position, radius, axis, color, thickness])














func track_properties(node:Spatial, properties:Array):
	if not node in _tracking_commands:
		_tracking_commands[node] = {}

	for p in properties:
		var type:String = p.pop_at(0)
		var id:String = p.pop_at(0)
		var dict := {}
		match type:
			'l', "ln", "line":
				if   p.size() == 4:	dict = _build_line_dict(p[0], p[1], p[2], p[3])
				else:               dict = _build_line_dict(p[0], p[1], p[2])
			'p', "pt", "point":
				if   p.size() == 3: dict = _build_point_dict(p[0], p[1], p[2])
				else:               dict = _build_point_dict(p[0], p[1])
			'v', "vec", "vector":
				if   p.size() == 4:	dict = _build_vector_dict(p[0], p[1], p[2], p[3])
				else:               dict = _build_vector_dict(p[0], p[1], p[2])
			't', "tr":
				if   p.size() == 3: dict = _build_transform_dict(node, p[0], p[1], p[2])
				elif p.size() == 2: dict = _build_transform_dict(node, p[0], p[1])
				else:               dict = _build_transform_dict(node, p[0])

			_: pass
		_tracking_commands[node][id] = dict




#func _track_prop_as_line(node:Spatial, p_info:Array): # Array[ String | Array[String, int] ]


func _process_tracking_commands():
	for node in _tracking_commands:
		var dict = _tracking_commands[node]
		if dict.size() == 0: continue

		for id in dict:
			var c = dict[id]
			match c.type:
				"line":      _schedule_draw("line", [node.get(c.start), node.get(c.end), c.color, c.thickness])
				"vector":    _schedule_draw("vector", [node.get(c.position), node.get(c.direction), c.color, c.thickness])
				"transform": _schedule_draw_transform(c.node, c.transf_name, c.size, c.thickness)
				"point":     _schedule_draw("point", [node.get(c.position), c.color, c.size])
				"circle": pass # no tracking data would ever be a circle, I think
				_:
					assert(false)



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#		internal drawing API
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
func _get_color_array(color:Color, size:int) -> Array:
	var colors := []
	for i in size:
		colors.append(color)
	return colors


func _check_colors(color:Color, size:int):
	if not color:      return _get_color_array(_curr_line_color, size)
	if color is Color: return _get_color_array(color, size)
	return color

func _schedule_draw(type, args) -> void:
	match type:
		"vector":
			_schedule_draw("line", [args[0], args[0]+args[1], args[2], args[3]])
			_schedule_draw("cone", [args[0]+args[1], args[1], args[2], args[3]])
		"line":      _lines.append(args)
		"cone":      _cones.append(args)
		"point":     _points.append(args)
		"circle":    _circles.append(args)
		_:
			assert(false)


func _schedule_draw_transform(node:Spatial, transf_name:String, size:float, thickness:float) -> void:
	if not _debugger._debugging or not active: return
	var tr = node.get(transf_name)
	var gtr = node.global_transform
	var basis = tr.basis.orthonormalized()

	_schedule_draw("vector", [gtr.origin, basis.x*size, Color.red, thickness])
	_schedule_draw("vector", [gtr.origin, basis.y*size, Color.green, thickness])
	_schedule_draw("vector", [gtr.origin, basis.z*size, Color(0, 0.133333, 1), thickness])


func _schedule_draw_point_as_cube(p:Vector3, color:=Color.white, size:=0.5) -> void:
	var s := size  # just an abreviation

	var a = Vector3(-s,  s, -s) + p    #  A
	var b = Vector3( s,  s, -s) + p    #  B
	var c = Vector3( s, -s, -s) + p    #  C
	var d = Vector3(-s, -s, -s) + p    #  D
	var e = Vector3(-s,  s,  s) + p    #  F
	var f = Vector3( s,  s,  s) + p    #  E
	var g = Vector3( s, -s,  s) + p    #  G
	var h = Vector3(-s, -s,  s) + p    #  H

	var f_verts := [
		a,e,h, a,h,d,  # West
		f,b,c, f,c,g,  # East
		b,a,d, b,d,c,  # North
		e,f,g, e,g,h,  # South
		a,b,f, a,f,e,  # Top
		h,g,c, h,c,d,  # Bottom
	]

	var f_colors := _get_color_array(color, f_verts.size())

#	_add_draw_command(Mesh.PRIMITIVE_TRIANGLES, f_verts, f_colors)

	var wf_verts := [
		a,b,  b,c,  c,d,  d,a,
		e,f,  f,g,  g,h,  h,e,
		a,e,  b,f,  c,g,  d,h
	]
	var wf_colors := []
	if color.v >= 0.5:
		wf_colors = _get_color_array(color.darkened(0.5), wf_verts.size())
	else:
		wf_colors = _get_color_array(color.lightened(0.5), wf_verts.size())

#	_add_draw_command(Mesh.PRIMITIVE_LINES, wf_verts, wf_colors)


