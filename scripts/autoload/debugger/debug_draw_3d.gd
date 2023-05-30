extends ImmediateGeometry

onready var _debugger:CanvasLayer = get_parent()

var active := true
var _draw_commands := []
var _curr_line_color = Color.white
var _named_commands := {}
var _tracking_commands := {}

func _ready() -> void:
	cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF

	var mat = SpatialMaterial.new()
	mat.vertex_color_use_as_albedo = true
	mat.params_line_width   = 5		# not working
	mat.flags_unshaded      = true
	mat.flags_no_depth_test = true
	mat.flags_transparent = true

	material_override = mat


func _redraw():
	clear()

	for dc in _draw_commands:
		begin(dc.prim_type)
		for i in dc.verts.size():
			set_color(dc.colors[i])
			add_vertex(dc.verts[i])
		end()

	_draw_commands.clear()


func _process(delta: float) -> void:
	if not _debugger._debugging or not active: return
	_process_named_commands()
	_process_tracking_commands()
	_redraw()




#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#		public 3D drawing API
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
const __DEF_ID = "__debug_default_id__"

#func _add_command_dict(id, dict):
#	_named_commands[id] = dict

#func draw_line(id, start, end, color) -> void:
#	if not _debugger._debugging or not active: return
#	if id is String: _add_command_dict(id,     _build_line_dict(start, end, color))
#	else:            _add_command_dict(__DEF_ID, _build_line_dict(id, start, end))


# KEEP THESE PARAMETERS TYPELESS
func _build_line_dict(start, end, color:Color) -> Dictionary:
	return {type = "line", start = start, end = end, color = color}

func _add_line(id:String, start:Vector3, end:Vector3, color:Color) -> void:
	_named_commands[id] = _build_line_dict(start, end, color)

func draw_line(id, start, end, color) -> void:
	if not _debugger._debugging or not active: return
	if id is String: _add_line(id, start, end, color)
	else:            _add_line(__DEF_ID, id, start, end)


# KEEP THESE PARAMETERS TYPELESS
func _build_vector_dict(position, direction, color:Color) -> Dictionary:
	return {type = "vector", position = position, direction = direction, color = color}

func _add_vector(id:String, position:Vector3, direction:Vector3, color:Color):
	_named_commands[id] = _build_vector_dict(position, direction, color)

func draw_vector(id, position, direction, color) -> void:
	if not _debugger._debugging or not active: return
	if id is String: _add_vector(id, position, direction, color)
	else:            _add_vector(__DEF_ID, id, position, direction)


# KEEP THESE PARAMETERS TYPELESS
func _build_point_dict(position, color:Color, size=null) -> Dictionary:
	var d := {type = "point", position = position, color = color}
	if size: d.size = size
	return d

func _add_point(id:String, position:Vector3, color:Color, size=null):
	_named_commands[id] = _build_point_dict(position, color, size)

func draw_point(id, position, color=null, size=null) -> void:
	if not _debugger._debugging or not active: return
	if id is String: _add_point(id, position, color, size)
	else:            _add_point(__DEF_ID, id, position, color)



#func _add_origin(id:String, position:Vector3, color:Color, size=null):
#	_named_commands[id] = _build_origin_dict(position, color, size)

func draw_origin(name, origin=null, size=null) -> void:
	if not _debugger._debugging or not active: return
	if name is String: _schedule_draw_origin(origin, size)
	else:              _schedule_draw_origin(name, origin)


# KEEP THESE PARAMETERS TYPELESS
func _build_transform_dict(_transform) -> Dictionary:
	return {type = "transform", transform=_transform}

func _add_transform(id:String, _transform:Transform) -> void:
	_named_commands[id] = _build_transform_dict(_transform)

func draw_transform(id, _transform) -> void:
	if not _debugger._debugging or not active: return
	if id is String: _add_transform(id, _transform)
	else:            _add_transform(__DEF_ID, id)



















func track_properties(node:Spatial, properties:Array):
	if not node in _tracking_commands:
		_tracking_commands[node] = {}

	for p in properties:
		var type = p.pop_at(0)
		match type:
			'l', "ln", "line":
				_tracking_commands[node] = _build_line_dict(p[0], p[1], p[2])
			'p', "pt", "point":
				if p.size() > 3: _tracking_commands[node] = _build_point_dict(p[0], p[1], p[2])
				else:            _tracking_commands[node] = _build_point_dict(p[0], p[1])
			'v', "vec", "vector":
				_tracking_commands[node] = _build_vector_dict(p[0], p[1], p[2])
			't', "tr", "transform":
				_tracking_commands[node] = _build_transform_dict(p[0])
			_: pass





#func _track_prop_as_line(node:Spatial, p_info:Array): # Array[ String | Array[String, int] ]


func _process_named_commands():
	for id in _named_commands:
		var c = _named_commands[id]

		match c.type:
			"line":      _schedule_draw_line(c.start, c.end, c.color)
			"vector":    _schedule_draw_vector(c.position, c.direction, c.color)
			"transform": _schedule_draw_transform(c.transform)
			"point":
				if "size" in c: _schedule_draw_point(c.position, c.color, c.size)
				else:           _schedule_draw_point(c.position, c.color)
			_:
				assert(false)


func _process_tracking_commands():
	for node in _tracking_commands:
		var c = _tracking_commands[node]
		if c.size() == 0: continue

		match c.type:
			"line":      _schedule_draw_line(node.get(c.start), node.get(c.end), c.color)
			"vector":    _schedule_draw_vector(node.get(c.position), node.get(c.direction), c.color)
			"transform": _schedule_draw_transform(node.get(c.transform))
			"point":
				if "size" in c: _schedule_draw_point(node.get(c.position), c.color, c.size)
				else:           _schedule_draw_point(node.get(c.position), c.color)
			_:
				assert(false)



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#		internal drawing API
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
func _add_draw_command(prim_type:int, verts:Array, colors:Array) -> void:
	_draw_commands.append({
		prim_type = prim_type,
		verts = verts,
		colors = colors,
	})


func _get_color_array(color:Color, size:int) -> Array:
	var colors := []
	for i in size:
		colors.append(color)
	return colors


func _check_colors(color:Color, size:int):
	if not color:      return _get_color_array(_curr_line_color, size)
	if color is Color: return _get_color_array(color, size)
	return color


func _schedule_draw_line(start:Vector3, end:Vector3, color:Color) -> void:
	_add_draw_command(Mesh.PRIMITIVE_LINES, [start, end], [color, color])


func _schedule_draw_vector(position:Vector3, direction:Vector3, color:Color) -> void:
	var start = position
	var end = position + direction
	_schedule_draw_line(start, end, color)


func _schedule_draw_point(p:Vector3, color:Color, size:=0.05) -> void:
	_schedule_draw_point_as_cube(p, color, size)


func _schedule_draw_origin(origin:Vector3, size:=0.5) -> void:
	if not _debugger._debugging or not active: return
	# TODO: this is untested. Probably doesn't work.

	var x_axis = Vector3(size, 0, 0)
	var y_axis = Vector3(0, size, 0)
	var z_axis = Vector3(0, 0, size)

	_schedule_draw_vector(origin, x_axis, Color.green)
	_schedule_draw_vector(origin, y_axis, Color.red)
	_schedule_draw_vector(origin, z_axis, Color.blue)


func _schedule_draw_transform(_transform:Transform) -> void:
	if not _debugger._debugging or not active: return
	_schedule_draw_vector(_transform.origin, _transform.basis.y*0.5, Color.green)
	_schedule_draw_vector(_transform.origin, _transform.basis.x*0.5, Color.red)
	_schedule_draw_vector(_transform.origin, _transform.basis.z*0.5, Color.blue)


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

	_add_draw_command(Mesh.PRIMITIVE_TRIANGLES, f_verts, f_colors)

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

	_add_draw_command(Mesh.PRIMITIVE_LINES, wf_verts, wf_colors)


