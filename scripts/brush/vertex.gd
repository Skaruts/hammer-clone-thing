extends RefCounted
class_name Vertex

var x:float
var y:float
var z:float
var normal:Vector3
var connected_verts := []

var vec:Vector3:
	get: return Vector3(x,y,z)
	set(v):
		x = v.x
		y = v.y
		z = v.z

func _init(pos:Vector3) -> void:
	if pos != null:
		x = pos.x
		y = pos.y
		z = pos.z


