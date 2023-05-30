extends CanvasLayer
# autoloaded script

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
# 		Debug
#
# 	Version 0.6.3 (Godot 3)
#
#   text instance
#   2d drawing instance
#   3d drawing instance
#
#  TODO:
#     consider having an update rate option, so I can choose to only update
#     every 2 frames or slower, or at a fixed timestep
#
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#	public properties
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
var text_scale := 1.0

var draw_background := true:
	get: return _bg_rect.visible
	set(enable): _bg_rect.visible = enable

var _def_bg_color = Color(0, 0, 0, 0.85)
var bg_color:
	get: return _bg_rect.color
	set(color): _bg_rect.color = color


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#	private properties
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#const Drawing3D = preload("res://scripts/autoload/debugger/debug_draw_3d.gd")
const Drawing3D = preload("res://scripts/autoload/debugger/debug_draw_3d_2.gd")


@onready var _bg_rect := ColorRect.new()
@onready var _label := Label.new()

var _draw_3d#:ImmediateGeometry
var _draw_2d:Node2D

var _debugging = false

var _rect_size := Vector2()


var _text := ""
var _nodes = {}
var _3d_instances := {}
#var _2d_instances := {}

var _node_associated_values := {}
#var _draw_commands_3d := []

const _DEF_FLOAT_PRECISION := 2
var _num_lines = 0





func create_3d_drawing(node_or_name, active:=true) -> Drawing3D:
	var name = ""
	if typeof(node_or_name) == TYPE_STRING:   name = node_or_name
	elif typeof(node_or_name) == TYPE_OBJECT: name = node_or_name.name

	if name in _3d_instances:
		print("instance3d already exists")
		return _3d_instances[name]

	var new_instance = Drawing3D.new()
	add_child(new_instance)
	new_instance.active = active
	_3d_instances[name] = new_instance
	return new_instance


func end_3d_drawing(node_or_name) -> void:
	var name = ""
	if typeof(node_or_name) == TYPE_STRING:   name = node_or_name
	elif typeof(node_or_name) == TYPE_OBJECT: name = node_or_name.name

	if not name in _3d_instances:
		print("instance3d doesn't exist")
		return
	_3d_instances[name].queue_free()
	_3d_instances.erase(name)



func _ready() -> void:
	layer = 128
	_nodes[self] = {}

	add_child(_bg_rect)
	_bg_rect.name = "debug_bg_rect"
	_bg_rect.color = _def_bg_color

	add_child(_label)
	_label.name = "debug_label"
	_label.scale = Vector2.ONE * text_scale
	_label.resized.connect(__on_label_resized)

#	add_child(_draw_3d)
	_draw_3d = create_3d_drawing(self)
	_draw_3d.name = "debug_draw_3d"
#	_draw_3d.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF

#	var mat = SpatialMaterial.new()
#	_draw_3d.material_override = mat
#
#	mat.vertex_color_use_as_albedo = true
#	mat.params_line_width   = 5		# not working
#	mat.flags_unshaded      = true
#	mat.flags_no_depth_test = true
#	mat.flags_transparent = true

#	add_child(draw_2d)
#	draw_2d.name = "debug_draw_2d"
#	draw_2d.update()


func __on_label_resized():
	_rect_size = _label.get_rect().size
#	_rect_size.y -= 14  # remove unintended extra space
	_bg_rect.size = _rect_size * text_scale


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode in [KEY_BACKSLASH, KEY_ASCIITILDE] \
		and event.pressed \
		and not event.echo:
			_toggle_on_off()


func _process(_delta: float) -> void:
	_num_lines = 0
	if not _debugging: return

	call_deferred("_process_properties")
	call_deferred("_process_3d_drawing")
	call_deferred("_finish_processing")


func _toggle_on_off():
	_debugging = not _debugging

#	draw_2d.visible = _debugging
	_draw_3d.visible = _debugging
	_label.visible   = _debugging
	_bg_rect.visible = _debugging # TODO: this overrides 'draw_background', as it is

	set_process(_debugging)


func _finish_processing():
	_label.text = _text
	_text = ""
	_node_associated_values.clear()
#	_draw_commands_3d.clear()

#	for i3d in _3d_instances:
#		i3d.clear_commands()

func _process_3d_drawing():
#	for i3d in _3d_instances:
#		i3d.redraw()
	pass


func _add_text_line(line, prefix=""):
	var line_text = ""
	var key = line.key
	var val = line.val

	if val != null:
		var str_val = prefix
		var precision:int = _DEF_FLOAT_PRECISION \
			if not line.has("fp")                \
			else line.fp
		if typeof(val) == TYPE_FLOAT:
			str_val = "%." + str(int(precision)) + "f"
			str_val = str_val % [val]
		elif typeof(val) == TYPE_VECTOR3:
			str_val = "(%."  + str(precision) + "f"    \
					+ ", %." + str(precision) + "f"    \
					+ ", %." + str(precision) + "f)"

			str_val = str_val % [val.x, val.y, val.z]
		else:
			str_val = str(val)   #TODO: shouldn't this be '+=' ?
		line_text += prefix + key + ": " + str_val + "\n"
	else:
		line_text += prefix + key + "\n"	# no 'val' given, assume key is 'val'

	_num_lines += 1
#	draw_2d.update()

	return line_text

func _process_properties():
	for node in _nodes:
		var line_text = ""
		if node != self:
			line_text += "\n" + node.name + "\n"

			for prop in _nodes[node].values():
				var prefix = "        " if node != self else ""
				var line := {
					key = prop.name,
					val = node.get(prop.name),
				}
				if prop.has("fp"):
					line.fp = prop.fp
				line_text += _add_text_line(line, prefix)

			_text += line_text

		line_text = ""
		if _node_associated_values.has(node):
			var prefix = "    " if node != self else ""
			for line in _node_associated_values[node]:
				line_text += _add_text_line(line, prefix)
			_text += line_text





#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#		Public API
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#func _add_property(node, name, precision=null):


func register(node:Object, properties:Array): # Array[ String | Array[String, int] ]
	# propery must contain 'name:String', and optionally 'fp:int' (float precision)
	if not _nodes.has(node):
		_nodes[node] = {}

	for p in properties:
		var dict = {}
		if typeof(p) == TYPE_ARRAY:
			dict.name = p[0]
			if p.size() > 1:
				dict.fp = p[1]
		else:
			dict = {name=p}

		_nodes[node][dict.name] = dict


func unregister(node, property_names=null):
	if not property_names:
		_nodes.erase(node)
	else:
		for name in property_names:
			_nodes[node].erase(name)
			if not _nodes[node].size():
				_nodes.erase(node)
				break

func print(key, val=null, node=self, float_precision=null) -> void:
	if not _debugging: return
	if not float_precision and typeof(node) == TYPE_INT:
		float_precision = node
		node = self

	var line := {
		key = key,
		val = val,
	}

	if float_precision:
		line["fp"] = float_precision

	if not _nodes.has(node):
		_nodes[node] = {}

	if not _node_associated_values.has(node):
		_node_associated_values[node] = []
	_node_associated_values[node].append(line)


func track_properties(node, properties:Array):
	if node is Node3D:
		_draw_3d.track_properties(node, properties)
#	elif node is Node2D:
#		_draw_2d.track_properties(node, properties)



#func _check_cache(name:String) -> Dictionary:
#	if not _bm_cache.has(name):
#		_bm_cache[name] = {
#			frames = 0,
#			time = 0,
#		}
#	return _bm_cache[name]
#
#func _count_frame(cached:Dictionary) -> void:
#	cached.frames += 1
#	if cached.frames > 500:
#		cached.frames = 1
#		cached.time = 0


## benchmark a function 'f'
#func bm(name:String, node, f:String) -> String:
#	var cached := _check_cache(name)
#	_count_frame(cached)
#
#	var t1:float = Time.get_ticks_msec()
#	f.call()
#	var t2:float = (Time.get_ticks_msec() - t1)/1000
#
#	cached.time += t2
#	var avg:float = cached.time/cached.frames
#
#	var times_str = "avg %4fs  |  tm %4fs" % [avg, t2]
#
#	if _debugging:
#		self.print("> " + name, times_str)
#
#	return "%s: " + times_str % [name]


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#		public drawing API
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=




func draw_vector(position, direction, color:Color, thickness:=1.0, id=null) -> void:
	if not _debugging: return
	if   position is Vector2: _draw_2d.draw_vector(position, direction, color, thickness, id)
	elif position is Vector3: _draw_3d.draw_vector(position, direction, color, thickness, id)


func draw_line(start, end, color:Color, thickness:=1.0, id=null) -> void:
	if not _debugging: return
	if   start is Vector2: _draw_2d.draw_line(start, end, color, thickness, id)
	elif start is Vector3: _draw_3d.draw_line(start, end, color, thickness, id)


func draw_transform(node:Node, transform_name:String, size:=1.0, thickness:=1.0, id=null) -> void:
	if not _debugging: return
	if   node is Node2D:  _draw_2d.draw_transform(node, transform_name, size, thickness, id)
	elif node is Node3D: _draw_3d.draw_transform(node, transform_name, size, thickness, id)

func draw_point(position, color:Color, size:=1.0, id=null) -> void:
	if not _debugging: return
	if   position is Vector2: _draw_2d.draw_point(position, color, size, id)
	elif position is Vector3: _draw_3d.draw_point(position, color, size, id)

func draw_circle(position, radius:float, axis:Vector3, color:Color, thickness:=1.0, id=null) -> void:
	_draw_3d.draw_circle(position, radius, axis, color, thickness, id)


func draw_text(position, text:String, color:Color, size:=1.0, id=null) -> void:
	if not _debugging: return
	if   position is Vector2: _draw_2d.draw_text(position, text, color, size, id)
	elif position is Vector3: _draw_3d.draw_text(position, text, color, size, id)
	pass
