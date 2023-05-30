extends Node2D

@onready var root = get_parent().get_parent().get_parent()

# Todo these colors might be better in data
# so the user can customize them
var color_x_axis := Color("aa0000")  # origin axes colors
var color_y_axis := Color("00aa00")
var color_z_axis := Color.BLUE

var _camera:Camera2D

var axis := Vector3.AXIS_X

var vert_handles := []


func _ready() -> void:
	_camera = get_parent().get_node("camera")


func _unhandled_input(_event:InputEvent) -> void:
	pass


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#        Public interface

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#        Internal stuff

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=


func _process(_delta):
	if not root.visible: return
#	debug.print("curr_lim", _limits[_curr_size_idx])
#	debug.print("curr_size", _sizes[_curr_size_idx])
#	debug.print("smallest_grid_possible", _sizes[smallest_grid_possible])
	pass



#var num = 0
func _draw() -> void:
	var map := data.get_current_map()

	match axis:
		Vector3.AXIS_X:
			draw_brushes_side(map.get_non_selected_brushes(), data.color_brush)
			draw_brushes_side(map.selected_brushes, data.color_brush_selected)
		Vector3.AXIS_Y:
			draw_brushes_top(map.get_non_selected_brushes(), data.color_brush)
			draw_brushes_top(map.selected_brushes, data.color_brush_selected)
		Vector3.AXIS_Z:
			draw_brushes_front(map.get_non_selected_brushes(), data.color_brush)
			draw_brushes_front(map.selected_brushes, data.color_brush_selected)
#			for brush in map.get_non_selected_brushes():
#				for e in brush.edges:
#					try_draw_edge(Vector2(e.v1.x, -e.v1.y), Vector2(e.v2.x, -e.v2.y), data.color_brush)
#
#			vert_handles.clear()
#
#			for brush in map.selected_brushes:
#				for v in brush.verts:
#					vert_handles.append(v)
#
#				pass




func try_draw_edge(a:Vector2, b:Vector2, color:Color) -> void:
	if a == b: return
	draw_line(a, b, color)

func draw_brushes_front(brushes:Array[Brush], color:Color) -> void:
	for brush in brushes:
		# if is_any_vert_visible(brush, vis_rect):
		for e in brush.edges:
			try_draw_edge(Vector2(e.v1.x, -e.v1.y), Vector2(e.v2.x, -e.v2.y), color)

func draw_brushes_side(brushes:Array[Brush], color:Color) -> void:
	for brush in brushes:
		# if is_any_vert_visible(brush, vis_rect):
		for e in brush.edges:
			try_draw_edge(Vector2(e.v1.z, -e.v1.y), Vector2(e.v2.z, -e.v2.y), color)

func draw_brushes_top(brushes:Array[Brush], color:Color) -> void:
	for brush in brushes:
		# if is_any_vert_visible(brush, vis_rect):
		for e in brush.edges:
			try_draw_edge(Vector2(e.v1.x, e.v1.z), Vector2(e.v2.x, e.v2.z), color)





#func is_any_vert_visible(brush:Brush, vis_rect:Rect2):
#	match view_side:
#		data.ViewSide.LEFT, data.ViewSide.RIGHT:
#			for v in brush.verts:
#				if vis_rect.has_point(Vector2(v.z, v.y)):
#					return true
#		data.ViewSide.TOP, data.ViewSide.BOTTOM:
#			for v in brush.verts:
#				if vis_rect.has_point(Vector2(v.x, v.z)):
#					return true
#		data.ViewSide.FRONT, data.ViewSide.BACK:
#			for v in brush.verts:
#				if vis_rect.has_point(Vector2(v.x, v.y)):
#					return true
#	return false
