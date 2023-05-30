extends CanvasLayer
# autoloaded script

# version 0.3.2 (Godot 4)

@onready var bg_rect := ColorRect.new()
@onready var label := Label.new()
@onready var im := ImmediateMesh.new()
@onready var draw_node := Node2D.new()
#onready var cdt := CanvasDrawTool3D.new() # vestige of an old dependency, no longer in use

var _debugging = true

var text := ""
var text_scale := 1.0
var draw_bg := true
var bg_color := Color(0,0,0,0.85)

# TODO: _rect_size based on amount of lines and screen size
var _rect_size := Vector2(300, 400)

var curr_line_color = Color.WHITE
var im_verts = []
var im_colors = []

var _nodes = {}
var _node_associated_values := {}
var _lines := []
const _DEF_FLOAT_PRECISION := 2
var num_lines = 0

var _bm_cache := {}



func _ready() -> void:
	layer = 128

	add_child(draw_node)

	add_child(bg_rect)
	bg_rect.color = bg_color
	bg_rect.size = _rect_size

	add_child(label)
	label.name = "debug_label"
	label.scale = Vector2.ONE * text_scale



#	add_child(cdt)
#	cdt.name = "CanvasDrawTool3D"
	var mi = MeshInstance3D.new()
	add_child(mi)
	mi.mesh = im
	mi.name = "debug_mesh"
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var mat = StandardMaterial3D.new()
	mi.material_override = mat

	mat.vertex_color_use_as_albedo = true
	mat.params_line_width   = 5		# not working in GLES2
	mat.flags_unshaded      = true
	mat.flags_no_depth_test = true
	mat.flags_transparent = true
	draw_node.queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode in [KEY_BACKSLASH, KEY_ASCIITILDE] \
		and event.pressed \
		and not event.echo:
			_toggle()


func _process(_delta: float) -> void:
	num_lines = 0
	if not _debugging: return

	call_deferred("_process_lines")
	call_deferred("_process_node_properties")
	call_deferred("_finish_processing")


func _toggle():
	_debugging = not _debugging
	visible = _debugging
	set_process(_debugging)


func _finish_processing():
	label.text = text
#
#	var size = label.label_settings.font.get_string_size(label.text)
#	bg_rect.size = size # Vector2(_rect_size.size.x, label.get_line_count()*20)

	text = ""

	im.clear_surfaces()
	if im_verts.size() > 0:
		im.surface_begin(Mesh.PRIMITIVE_LINES)

		for i in im_verts.size():
			im.surface_set_color(im_colors[i])
			im.surface_add_vertex(im_verts[i])

		im.surface_end()

		im_verts.clear()
		im_colors.clear()

	_node_associated_values.clear()
	_lines.clear()


func _process_lines():
	for line in _lines:
		_add_line(line)


func _add_line(line, prefix=""):
	var key = line.key
	var val = line.val

	if val != null:
		var str_val = prefix
		var precision:int = _DEF_FLOAT_PRECISION \
			if not line.has("float_precision") \
			else line.float_precision
		if typeof(val) == TYPE_FLOAT:
			str_val = "%." + str(int(precision)) + "f"
			str_val = str_val % [val]
		elif typeof(val) == TYPE_VECTOR3:
			str_val = "(%." + str(precision) + "f" \
					+ ", %." + str(precision) + "f"\
					+ ", %." + str(precision) + "f)"
			str_val = str_val % [val.x, val.y, val.z]
		else:
			str_val = str(val)   #TODO: shouldn't this be '+=' ?
		text += prefix + key + ": " + str_val + "\n"
	else:
		text += prefix + str(key) + "\n"	# no 'val' given, assume key is 'val'

	num_lines += 1
	draw_node.queue_redraw()


func _process_node_properties():
	for node in _nodes:
		text += "\n" + node.name + "\n"
		for prop in _nodes[node].values():
			var line := {
				key = prop.name,
				val = node.get(prop.name),
				fp = prop.precision,
			}
			_add_line(line, "        ")

		if _node_associated_values.has(node):
			for line in _node_associated_values[node]:
				_add_line(line, "      ")








#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#		Public API
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#func _add_property(node, name, precision=null):


func register(node:Object, property_name:String, float_precision=null):
	if not _nodes.has(node):
		_nodes[node] = {}
#	_add_property(node, property_name, float_precision)
	var prop = {
		name = property_name,
		precision = float_precision,
	}
	_nodes[node][property_name] = prop

func unregister(node, property_name=null):
	if not property_name:
		_nodes.erase(node)
	else:
		_nodes[node].erase(property_name)
		if not _nodes[node].size():
			_nodes.erase(node)

func print(key, val=null, node=null, float_precision=null) -> void:
	if not _debugging: return
	if not float_precision and typeof(node) == TYPE_INT:
		float_precision = node
		node = null

	var line := {
		key = key,
		val = val,
	}

	if float_precision:
		line["float_precision"] = float_precision

	if typeof(node) == TYPE_OBJECT:
		if not _node_associated_values.has(node):
			_node_associated_values[node] = []
		_node_associated_values[node].append(line)
	else:
		_lines.append(line)




func _check_cache(name:String) -> Dictionary:
	if not _bm_cache.has(name):
		_bm_cache[name] = {
			frames = 0,
			time = 0,
		}
	return _bm_cache[name]

func _count_frame(cached:Dictionary) -> void:
	cached.frames += 1
	if cached.frames > 500:
		cached.frames = 1
		cached.time = 0


# benchmark a function 'f'
func bm(name:String, f:Callable) -> String:
	var cached := _check_cache(name)
	_count_frame(cached)

	var t1:float = Time.get_ticks_msec()
	f.call()
	var t2:float = (Time.get_ticks_msec() - t1)/1000

	cached.time += t2
	var avg:float = cached.time/cached.frames

	var times_str = "avg %4fs  |  tm %4fs" % [avg, t2]

	if _debugging:
		self.print("> " + name, times_str)

	return "%s: " + times_str % [name]


#func add_circle(position: Vector3, radius: float, color: Color) -> void:
#	cdt.circle(position, radius, color)
#	cdt.update()

#func clear(full=false):
#	im.clear()
#	if full:
#		im_verts.clear()
#		im_colors.clear()


func set_color(color:Color):
	curr_line_color = color


# func _draw_position(pos:Vector3, color:Color) -> void:
# 	var colors:Array = _check_colors(verts.size(), color)


func draw_line_3d(verts:Array, color):
	var colors:Array = _check_colors(verts.size(), color)

	im_verts += verts
	im_colors += colors


func _set_colors(size, color) -> Array:
	var colors := []
	for i in size:
		colors.append(color)
	return colors


func _check_colors(size, color) -> Array:
	if not color:      return _set_colors(size, curr_line_color)
	if color is Color: return _set_colors(size, color)
	return color


#func draw_sphere(position):
