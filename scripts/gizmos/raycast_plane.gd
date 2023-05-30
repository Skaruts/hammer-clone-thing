#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#       Class for detecting mouse clicks and mouse dragging

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
class_name RaycastPlane extends StaticBody3D

enum {
	X  = 1,  # why not zero? I forgot...
	Y  = 2,
	XY = 3,
	Z  = 4,
	XZ = 5,
	ZY = 6,
}

enum {
	STATIC,
	DYNAMIC,
}

var _mode:int = STATIC
var mode:int:
	get: return _mode
	set(m): _mode = m

var layer:int = 0x1:
	get: return collision_layer
	set(layer):
		layer = layer
		collision_layer = layer
		collision_mask = layer


var _current_axis:int
var _callback:Callable

var _collider:CollisionShape3D
var _camera:Camera3D # = get_viewport().get_camera()

func _enter_tree() -> void:
	pass

func _ready() -> void:
	_camera = get_viewport().get_camera_3d()

	# NOTE: this was all on enter tree
#	$CollisionShape.shape = $CollisionShape.shape.duplicate()  # make unique
	_collider = CollisionShape3D.new()
	_collider.shape = WorldBoundaryShape3D.new()
#	_collider.shape.plane = Plane(0,0,1,0)
	add_child(_collider)

	sleep()
	# set_axis(X)


# TODO: check if this works reliably (seems to, so far),
# This is preferable to doing it in _proceess, since it allows using
# low CPU mode (OS.low_processor_usage_mode).
# Whenever there's any input, adjust the facing of the plane.
func _unhandled_input(event:InputEvent) -> void:
	_adjust_facing()


func _on_self_input_event(camera:Node, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int) -> void:
	_callback.call(camera, event, click_position, click_normal, shape_idx)


func set_relay(callback:Callable) -> void:
	input_event.connect(_on_self_input_event)
	_callback = callback


func unset_relay():
	input_event.disconnect(_on_self_input_event)
#	_callback = null


func reset() -> void:
	# _collider.transform.basis = Basis()
	_collider.shape.plane = Plane.PLANE_XZ
	_collider.rotation = Vector3.ZERO
	_current_axis = XZ


# --- reference ---
# PLANE_YZ = Plane( 1, 0, 0, 0 ) -- A plane that extends in YZ axes (normal vector points +X).
# PLANE_XZ = Plane( 0, 1, 0, 0 ) -- A plane that extends in XZ axes (normal vector points +Y).
# PLANE_XY = Plane( 0, 0, 1, 0 ) -- A plane that extends in XY axes (normal vector points +Z).
# -----------------
func set_axis(axis:int) -> void:
	if axis != _current_axis:
		# reset()
		_current_axis = axis
		match axis:
			X, Y, Z, XY: _collider.shape.plane = Plane.PLANE_XY
			ZY:          _collider.shape.plane = Plane.PLANE_YZ
			XZ:          _collider.shape.plane = Plane.PLANE_XZ

# TODO: rethink this. Currently this assumes the camera is a character
# camera, with a parent that rotates separately around Y, while the
# camera rotates around X. This class shouldn't make assumptions about
# its user.
func _adjust_facing() -> void:
	if _current_axis == X:
		var cam_pos:Vector3 = _camera.get_parent().position
		var point = Vector3(position.x, cam_pos.y, cam_pos.z)
		_collider.look_at(point, Vector3.UP)

	elif _current_axis == Y:
		_collider.rotation.y = _camera.get_parent().rotation.y

	elif _current_axis == Z:
		var cam_pos:Vector3 = _camera.get_parent().position
		var point = Vector3(cam_pos.x, cam_pos.y, position.z)
		_collider.look_at(point, Vector3.UP)


# TODO: I never know which one is needed here, layer or mask?
func sleep() -> void:
	if mode == DYNAMIC:
		set_process_unhandled_input(false)
#		reset() #<-- this could be in wake()
	collision_layer = 0
	collision_mask = 0


func wake(pos:Vector3, axis:int) -> void:
	if mode == DYNAMIC:
		set_process_unhandled_input(true)
		reset()
	collision_layer = layer
	collision_mask = layer
	position = pos
	set_axis(axis)

	if mode == DYNAMIC:
		_adjust_facing()


func get_drag_position(obj_pos:Vector3, click_pos:Vector3) -> Vector3:
	match _current_axis:
		X:     return Vector3(click_pos.x, obj_pos.y,   obj_pos.z)
		Y:     return Vector3(obj_pos.x,   click_pos.y, obj_pos.z)
		Z:     return Vector3(obj_pos.x,   obj_pos.y,   click_pos.z)
		XY:    return Vector3(click_pos.x, click_pos.y, obj_pos.z)
		ZY:    return Vector3(obj_pos.x,   click_pos.y, click_pos.z)
		XZ:    return Vector3(click_pos.x, obj_pos.y,   click_pos.z)
	return Vector3.ZERO



