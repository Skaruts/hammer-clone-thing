extends Control

signal pan_mode_entered
signal pan_mode_exited

@onready var vp1 := %top_left_vp
@onready var vp2 := %top_right_vp
@onready var vp3 := %bottom_left_vp
@onready var vp4 := %bottom_right_vp

var mouse_hidden := false
var active_camera := 0
var vps := []
var prev_mouse_pos:Vector2

enum RevertMouseOptions {
	LAST_POSITION,
	VIEWPORT_CENTER
}

var revert_mouse_setting := RevertMouseOptions.LAST_POSITION

func _process(_delta):
	debug.print("active_vp", active_camera)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _ready():
#	ProjectSettings.set_setting("display/window/size/always_on_top", true)
	RenderingServer.set_default_clear_color(Color.BLACK)
	OS.low_processor_usage_mode = true


	vps = [%top_left_vp, %top_right_vp, %bottom_left_vp, %bottom_right_vp]

	vp2.set_axis(Vector3.AXIS_Y)
	vp3.set_axis(Vector3.AXIS_Z)
	vp4.set_axis(Vector3.AXIS_X)

	for i in vps.size():
#		if i == 0: continue
		var vp = vps[i]
		vp.get_camera().pan_mode_entered.connect(_on_vp_pan_mode_entered)
		vp.get_camera().pan_mode_exited.connect(_on_vp_pan_mode_exited)

	vps[0].mouse_entered.connect(_on_vp0_mouse_entered)
	vps[1].mouse_entered.connect(_on_vp1_mouse_entered)
	vps[2].mouse_entered.connect(_on_vp2_mouse_entered)
	vps[3].mouse_entered.connect(_on_vp3_mouse_entered)


func _on_vp_pan_mode_entered(): hide_mouse()
func _on_vp_pan_mode_exited():  show_mouse()


func activate_vp(idx:int):
	vps[active_camera].disable()
	active_camera = idx
	vps[active_camera].enable()


func _on_vp0_mouse_entered(): if not mouse_hidden: activate_vp(0)
func _on_vp1_mouse_entered(): if not mouse_hidden: activate_vp(1)
func _on_vp2_mouse_entered(): if not mouse_hidden: activate_vp(2)
func _on_vp3_mouse_entered(): if not mouse_hidden: activate_vp(3)


func _revert_mouse_pos():
#	await get_tree().process_frame
	match revert_mouse_setting:
		RevertMouseOptions.LAST_POSITION:
#			Input.warp_mouse(prev_mouse_pos)
			DisplayServer.warp_mouse(prev_mouse_pos)
		RevertMouseOptions.VIEWPORT_CENTER:
			var vp = vps[active_camera]
			var rect = vp.get_global_rect()
#			Input.warp_mouse( (rect.size/2) + rect.position )
			DisplayServer.warp_mouse( (rect.size/2) + rect.position )

func enable_mouse(enable):
	if enable: show_mouse()
	else:      hide_mouse()

func hide_mouse():
#	print("hide_mouse")
	mouse_hidden = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	prev_mouse_pos = get_global_mouse_position()

func show_mouse():
#	print("show_mouse")
	mouse_hidden = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_revert_mouse_pos()


