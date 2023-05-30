extends Node2D

@onready var root = get_parent().get_parent().get_parent()
@onready var _map := data.get_current_map()



# var grid_size:int = _map.grid_size  # size of the grid
# var _w:int # = (32*grid_size)/2.0
# var _h:int # = (32*grid_size)/2.0

#var origin_size :int = 3   # size of the origin axes lines
#var xz_steps    :int = 8   # how many lines to skip between axis grid lines

# Todo these colors might be better in data
# so the user can customize them
var color_x_axis := Color("aa0000")  # origin axes colors
var color_y_axis := Color("00aa00")
var color_z_axis := Color.BLUE

var color_grid_1 := Color("333333")  # grid color
var color_grid_2 := color_grid_1.lightened(0.05)  # grid color
var color_grid_3 := color_grid_2.lightened(0.05)  # grid color
# var color_grid_4 := color_grid_3.lightened(0.05)  # grid color
var color_grid_sub := Color("1f123d")

var color_grid_1024 := Color("9c653e")

var _origin:MeshInstance2D
var _camera:Camera2D

enum {
	GRID_0_125,
	GRID_0_25,
	GRID_0_5,
	GRID_1,
	GRID_2,
	GRID_4,
	GRID_8,
	GRID_16,
	GRID_32,
	GRID_64,
	GRID_128,
	GRID_256,
	GRID_512,
	GRID_1024,
	MAX_GRIDS,
}
var _limits := [
#	Vector2(0.2, 0.2),     # GRID_1
#	Vector2(0.4, 0.4),     # GRID_2
#	Vector2(0.8, 0.8),     # GRID_4
#	Vector2(1.9, 1.9),     # GRID_8
#	Vector2(4.0, 4.0),     # GRID_16
#	Vector2(8.0, 8.0),     # GRID_32
#	Vector2(12.0, 12.0),   # GRID_64
#	Vector2(29.0, 29.0),   # GRID_128
#	Vector2(999.0, 999.0), # GRID_256
#	Vector2(999.0, 999.0), # GRID_512
#	Vector2(999.0, 999.0), # GRID_1024

	Vector2(1,1) * 45.0,   # GRID_0_125
	Vector2(1,1) * 25.0,   # GRID_0_25
	Vector2(1,1) * 14.0,   # GRID_0_5
	Vector2(1,1) * 7.0,    # GRID_1
	Vector2(1,1) * 3.5,    # GRID_2
	Vector2(1,1) * 1.5,    # GRID_4
	Vector2(1,1) * 0.9,    # GRID_8
	Vector2(1,1) * 0.5,    # GRID_16
	Vector2(1,1) * 0.35,   # GRID_32
	Vector2(1,1) * 0.1,    # GRID_64
	Vector2(1,1) * 0.05,   # GRID_128
	Vector2(),          # GRID_256
	Vector2(),          # GRID_512
	Vector2(),          # GRID_1024

]

var _sizes:Array[float] = [0.125, 0.25, 0.5, 1,2,4,8,16,32,64,128,256,512,1024] as Array[float]

var _curr_size_idx := 0

func _ready() -> void:
	_camera = get_parent().get_node("camera")

	_origin = MeshInstance2D.new()
	add_child(_origin)
	_origin.name = "Origin"

	_create_origin()
	set_grid_size(GRID_2)
	queue_redraw()


func _unhandled_input(event:InputEvent) -> void:
	if   event.is_action_pressed("increase_grid"): next_size()
	elif event.is_action_pressed("decrease_grid"): prev_size()




#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#        Public interface

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

func set_grid_size(size_idx:int) -> void:
	if size_idx != _curr_size_idx:
		_map.grid_size = _sizes[size_idx]
		_curr_size_idx = size_idx
		if root.visible:
			print("%s | %s" % [_sizes[_curr_size_idx], _map.grid_size])


func next_size() -> void:
	var size_idx = min(MAX_GRIDS-1, _curr_size_idx+1)
	set_grid_size(size_idx)

func prev_size() -> void:
	var size_idx = max(0, _curr_size_idx-1)
	set_grid_size(size_idx)

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#        Internal stuff

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=


func _draw_grid(color:Color, gs:float, vp_size:Vector2, ofs:Vector2) -> void:
	var left   := ((ofs.x - vp_size.x) / gs) - 1
	var right  := ((vp_size.x + ofs.x) / gs) + 1
	var top    := ((ofs.y - vp_size.y) / gs) - 1
	var bottom := ((vp_size.y + ofs.y) / gs) + 1

	for x in range(left, right):
		draw_line(Vector2(x*gs, ofs.y+vp_size.y+100), Vector2(x*gs, ofs.y-vp_size.y-100), color)

	for y in range(top, bottom):
		draw_line(Vector2(ofs.x+vp_size.x+100, y*gs), Vector2(ofs.x-vp_size.x-100, y*gs), color)


#func _draw_gridf(color:Color, gs:float, vp_size:Vector2, ofs:Vector2) -> void:
#	var left   := ((ofs.x - vp_size.x) / gs) - 1
#	var right  := ((vp_size.x + ofs.x) / gs) + 1
#	var top    := ((ofs.y - vp_size.y) / gs) - 1
#	var bottom := ((vp_size.y + ofs.y) / gs) + 1
#
#	for x in range(left, right):
#		draw_line(Vector2(x*gs, ofs.y+vp_size.y+100), Vector2(x*gs, ofs.y-vp_size.y-100), color)
#
#	for y in range(top, bottom):
#		draw_line(Vector2(ofs.x+vp_size.x+100, y*gs), Vector2(ofs.x-vp_size.x-100, y*gs), color)

func _process(_delta):
	if root.visible:
		debug.print("curr_lim", _limits[_curr_size_idx])
		debug.print("curr_size", _sizes[_curr_size_idx])
		debug.print("smallest_grid_possible", _sizes[smallest_grid_possible])



var smallest_grid_possible
func _draw() -> void:
#	var gs:float = _map.grid_size
	var vp_size = get_viewport_rect().size / (_camera.zoom)
	var ofs = _camera.offset

	smallest_grid_possible = _curr_size_idx
	while smallest_grid_possible <= GRID_512:
		if _camera.zoom > _limits[smallest_grid_possible]: break
		smallest_grid_possible += 1
#
#	if root.visible:
#		print(_curr_size_idx, " | ", _sizes[smallest_grid_possible], " | ", _camera.zoom, " | ", _limits[GRID_64])
#
#
	match smallest_grid_possible:
		GRID_0_125, GRID_0_25, GRID_0_5:
			_draw_grid(color_grid_sub, _sizes[smallest_grid_possible], vp_size, ofs)
			_draw_grid(color_grid_3, _sizes[GRID_1], vp_size, ofs)
		GRID_1:
#			if _camera.zoom > _limits[GRID_0_5]:
#				_draw_grid(color_grid_3, _sizes[smallest_grid_possible], vp_size, ofs)
#			else:
			_draw_grid(color_grid_1, _sizes[smallest_grid_possible], vp_size, ofs)
		GRID_2, GRID_4, GRID_8, GRID_16, GRID_32:
			_draw_grid(color_grid_1, _sizes[smallest_grid_possible], vp_size, ofs)
		GRID_64, GRID_128, GRID_256:
			_draw_grid(color_grid_3, _sizes[smallest_grid_possible], vp_size, ofs)

	if _curr_size_idx < GRID_64 and _camera.zoom > _limits[GRID_64]:
		_draw_grid(color_grid_3, 64, vp_size, ofs)

	if _curr_size_idx <= GRID_512:
		_draw_grid(color_grid_3, 512, vp_size, ofs)

	_draw_grid(color_grid_1024, 1024, vp_size, ofs)


const VINF:int = 0x7fffffff  # virtually infinite
func _create_origin() -> void:
	var axis1_color = color_x_axis
	var axis2_color = color_y_axis

	if root.axis == Vector3.AXIS_Y:
		axis2_color = color_z_axis
	elif root.axis == Vector3.AXIS_X:
		axis1_color = color_z_axis

	var m:ArrayMesh = MeshUtils.build_mesh_2d([{
		primitive_type = Mesh.PRIMITIVE_LINES,
		vertices = [
			Vector2( -VINF,  0 ),	Vector2( VINF,  0 ),
			Vector2(  0, -VINF ),	Vector2(  0, VINF ),
		],
		colors = [
			axis1_color,	axis1_color,
			axis2_color,	axis2_color,
		],

	}])

	_origin.mesh = m



