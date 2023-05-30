extends RefCounted
class_name Edge

var v1:Vertex
var v2:Vertex
var faces:Array[Face]
#var brush:Brush

func _init(_a:Vertex, _b:Vertex) -> void:
	v1 = _a
	v2 = _b

