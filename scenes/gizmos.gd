extends Node2D

@onready var root = get_parent().get_parent().get_parent()

var _camera:Camera2D

var axis := Vector3.AXIS_X

var bb_color := Color(0.2, 0.5, 0.7, 1)
var bb_fill_color := Color(bb_color, 0.15)
var bb_fill_colors:Array[Color] = [bb_fill_color,bb_fill_color,bb_fill_color,bb_fill_color]
var bb_thickness := 5
var bb_antialiased := true
var bb_corner_radius := 12
var bb_stylebox:StyleBoxFlat

func _ready() -> void:
	bb_stylebox = StyleBoxFlat.new()
	bb_stylebox.border_color = bb_color
	bb_stylebox.bg_color = bb_fill_color
	bb_stylebox.set_border_width_all(bb_thickness)
	bb_stylebox.set_corner_radius_all(bb_corner_radius)

	_camera = get_parent().get_node("camera")

func calculate_size(a:Vector2, b:Vector2) -> Vector2:
	var size := (a-b).abs()
	if size.x <= 1: size.x = bb_thickness
	if size.y <= 1: size.y = bb_thickness
	return size

func _draw() -> void:
	var map = data.get_current_map()

	match axis:
		Vector3.AXIS_X:
			if map.selection_bb != null:
				var p1:Vector3 = map.selection_bb.p1
				var p2:Vector3 = map.selection_bb.p2

				var a := Vector2(min(p1.z, p2.z), min(-p1.y, -p2.y)) / data.editor_unit_size
				var b := Vector2(max(p1.z, p2.z), max(-p1.y, -p2.y)) / data.editor_unit_size

				var size := calculate_size(a, b)
				draw_style_box(bb_stylebox, Rect2(a, size))
		Vector3.AXIS_Y:
			if map.selection_bb != null:
				var p1:Vector3 = map.selection_bb.p1
				var p2:Vector3 = map.selection_bb.p2

				var a := Vector2(min(p1.x, p2.x), min(p1.z, p2.z)) / data.editor_unit_size
				var b := Vector2(max(p1.x, p2.x), max(p1.z, p2.z)) / data.editor_unit_size

				var size := calculate_size(a, b)
				draw_style_box(bb_stylebox, Rect2(a, size))
		Vector3.AXIS_Z:
			if map.selection_bb != null:
				var p1:Vector3 = map.selection_bb.p1
				var p2:Vector3 = map.selection_bb.p2

				var a := Vector2(min(p1.x, p2.x), min(-p1.y, -p2.y)) / data.editor_unit_size
				var b := Vector2(max(p1.x, p2.x), max(-p1.y, -p2.y)) / data.editor_unit_size

				var size := calculate_size(a, b)
				draw_style_box(bb_stylebox, Rect2(a, size))


