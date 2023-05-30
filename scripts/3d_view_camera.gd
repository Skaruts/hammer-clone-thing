extends CharacterBody3D # just so I can make it collide if I want

signal pan_mode_entered
signal pan_mode_exited

@onready var camera:Camera3D = $Camera3D
#@onready var viewport := get_viewport()

var fly_mode := true				# turn WASDetc movement on/off
var lock_horz := false			# lock to xz plane


var look_mode := false			# mouse look mode

var yaw              := 0.0
var pitch            := 0.0
var mouse_sens_pitch := 2.2
var mouse_sens_yaw   := 2.2
const PITCH_LIMIT    := PI/2

const FLY_ACCEL  := 14
const SPEED_MULT := 3
var fly_speed    := 0.05
#var velocity     = Vector3()



#func _enter_tree():
#	core.add_object(self, "EditorCamera")

func _process(_delta:float) -> void:
	debug.print("look_mode", look_mode)


func _physics_process(delta):
#	_center_mouse()
	if lock_horz:	fly_xz(delta)
	else:			fly_aim(delta)


# TODO: '_unhandled_input' doesn't get any mouse input, except mouse wheel

func _input(event):
#func _unhandled_input(event):
#	print(get_parent().get_parent().name, " | ", event)

	if event.is_action_pressed("mouse_look"):
		look_mode = true
		emit_signal("pan_mode_entered")
#		print("look_mode on: ", look_mode)

	elif event.is_action_released("mouse_look"):
		look_mode = false
		emit_signal("pan_mode_exited")

#	print("look_mode: ", look_mode)

	# Camera motion
	if event is InputEventMouseMotion and look_mode:
		yaw = fmod(yaw - event.relative.x * mouse_sens_yaw/10, 360)
		pitch = max(min(pitch - event.relative.y * mouse_sens_pitch/10, 90), -90)

		rotation = Vector3(0, deg_to_rad(yaw), 0)
		camera.rotation = Vector3(deg_to_rad(pitch), 0, 0)

	# Show mouse
#	if event.is_action_pressed("editor_mouse_capture"):

#	if event.is_action_pressed("ui_cancel"):
##	if Input.is_key_pressed(KEY_BACKSLASH):
#		show_mouse()


func set_orientation(pos, rot):
	yaw = rot.x
	pitch = rot.y
	position = pos
	rotation = Vector3(0, deg_to_rad(yaw), 0)
	camera.rotation = Vector3(deg_to_rad(pitch), 0, 0)


func get_curr_rotation() -> Vector3:
	return Vector3(camera.rotation.x, rotation.y, 0)



# fly locked to XZ plane
func fly_xz(delta):
	var dir = Vector3()
	var spd = fly_speed

	if Input.is_key_pressed(KEY_W):			dir.z -= 1
	if Input.is_key_pressed(KEY_S):			dir.z += 1
	if Input.is_key_pressed(KEY_A):			dir.x -= 1
	if Input.is_key_pressed(KEY_D):			dir.x += 1
	if Input.is_key_pressed(KEY_SPACE):		dir.y += 0.4
	if Input.is_key_pressed(KEY_CTRL):	    dir.y -= 0.4
	if Input.is_key_pressed(KEY_SHIFT):		spd *= SPEED_MULT

	var target = dir*spd
	velocity = velocity.lerp( target, FLY_ACCEL*delta )

	translate( velocity )


# fly towards where camera is looking
func fly_aim(delta):
	var aim = camera.get_camera_transform().basis

	var dir = Vector3()
	var spd = fly_speed
	if Input.is_key_pressed(KEY_W):			dir -= aim[2]
	if Input.is_key_pressed(KEY_S):			dir += aim[2]
	if Input.is_key_pressed(KEY_A):			dir -= aim[0]
	if Input.is_key_pressed(KEY_D):			dir += aim[0]
	if Input.is_key_pressed(KEY_SHIFT):		spd *= SPEED_MULT
	if Input.is_key_pressed(KEY_CTRL):		spd /= SPEED_MULT
	dir = dir.normalized()

	var target = dir * spd * 100
	velocity = velocity.lerp( target, FLY_ACCEL*delta )
	move_and_slide()






func set_fly_mode(enable):
	set_physics_process(enable)








