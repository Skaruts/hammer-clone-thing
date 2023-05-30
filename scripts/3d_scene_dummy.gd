extends Node3D

#@onready var box1 = $CSGBox3D
var brush:Brush

func _ready():
	$fly_camera.set_orientation(
		Vector3(10, 10, 10 ),
		Vector3(45, -35, 0)
	)


func _on_static_body1_3d_input_event(camera, event, position, normal, shape_idx):
	print("1 - _on_static_body_3d_input_event  | ", event)

func _on_static_body2_3d_input_event(camera, event, position, normal, shape_idx):
	print("2 - _on_static_body_3d_input_event  | ", event)

func _on_static_body3_3d_input_event(camera, event, position, normal, shape_idx):
	print("3 - _on_static_body_3d_input_event  | ", event)

