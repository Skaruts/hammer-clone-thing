extends Node
# autoloaded script

# Version 0.2 (Godot 4)

var key_actions = {
	nudge_up         = [{k=KEY_UP}],
	nudge_down       = [{k=KEY_DOWN}],
	nudge_left       = [{k=KEY_LEFT}],
	nudge_right      = [{k=KEY_RIGHT}],
	move_forward     = [{k=KEY_W}],
	move_back        = [{k=KEY_S}],
	move_left        = [{k=KEY_A}],
	move_right       = [{k=KEY_D}],
	move_faster      = [{k=KEY_SHIFT}],
	toggle_move_mode = [{k=KEY_Z}],
	increase_grid    = [{k=KEY_PERIOD}],
	decrease_grid    = [{k=KEY_COMMA}],
	undo             = [{k=KEY_Z, m=[KEY_CTRL]}],
	redo             = [{k=KEY_Z, m=[KEY_CTRL, KEY_SHIFT]}, {k=KEY_Y, m=[KEY_CTRL]}],
}

var mouse_actions = {
	"mouse_look" = [MOUSE_BUTTON_MIDDLE],
	"zoom_in"    = [MOUSE_BUTTON_WHEEL_UP],
	"zoom_out"   = [MOUSE_BUTTON_WHEEL_DOWN],
}

func _init() -> void:
	for action in key_actions:
		if InputMap.has_action(action):
			print("action already exists: ", action)
			continue

		InputMap.add_action(action)
		for binds in key_actions[action]:
			var e = InputEventKey.new()
			e.keycode = binds.key

			InputMap.action_add_event(action, e)


# TODO
func change_key(action:String, key_idx:int, old_key:int, new_key:int) -> void:
	# 'key_idx' is the index inside the array of keys of the action
	# (for allowing multiple keys for each action)

	# TODO: 'old_key' is probably not needed here

	pass

