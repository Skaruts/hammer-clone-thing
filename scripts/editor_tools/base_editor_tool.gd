class_name EditorTool extends Node3D

var map:MapDocumentBrush

func _init(_map:MapDocumentBrush) -> void:
	map = _map





func on_mouse_pressed(_axis:Vector3, _start:Vector3, _end:Vector3) -> void:
	assert(false, "To be overriden")


func on_mouse_released(_axis:Vector3, _start:Vector3, _end:Vector3) -> void:
	assert(false, "To be overriden")


func on_mouse_dragged(_axis:Vector3, _relative:Vector2) -> void:
	assert(false, "To be overriden")


