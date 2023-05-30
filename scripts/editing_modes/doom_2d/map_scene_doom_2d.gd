extends Node3D

#@onready var box1 = $CSGBox3D
var brush:Brush

func _ready():
	$fly_camera.set_orientation(
		Vector3(10, 10, 10 ),
		Vector3(45, -35, 0)
	)


