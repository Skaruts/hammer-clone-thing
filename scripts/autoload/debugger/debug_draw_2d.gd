extends Node2D

onready var _debugger:CanvasLayer = get_parent()

var active := true
var _draw_commands := []
var _curr_line_color = Color.white


func _draw_line_2d(start:Vector2, end:Vector2, color:Color) -> void:
	pass

func _draw_vector_2d(position:Vector2, direction:Vector2, color:Color) -> void:
	pass

func _draw_point_2d(p:Vector2, color:Color, size:=0.05) -> void:
	pass

func _draw_origin_2d(origin:Vector2, size:=0.5) -> void:
	pass

func _draw_transform_2d(_transform:Transform2D) -> void:
	pass
