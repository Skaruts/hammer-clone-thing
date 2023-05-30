extends Camera2D

@onready var root = get_parent().get_parent().get_parent()

var tween:Tween
var grid:Node2D

# onready var viewport_container:ViewportContainer = get_parent().get_parent().get_parent()

const MIN_ZOOM := Vector2(1,1) * 0.03
const MAX_ZOOM := Vector2(1,1) * 100.0
var _precomputed_zooms := []
var _curr_zoom_step:int = data.default_zoom_step
var _max_zoom_steps:int = 0

var is_panning := false

func _ready():
	grid = get_parent().get_node("grid")

#	tween = create_tween() #Tween.new()
##	add_child(tween)
#	tween.connect("step_finished", _on_tween_step)

	set_zoom_steps(data.zoom_factor)
	zoom = _precomputed_zooms[_curr_zoom_step]



func set_zoom_steps(factor:float) -> void:
	_precomputed_zooms = []
	data.zoom_factor = factor

	var val := MIN_ZOOM
	while val < MAX_ZOOM:
		_precomputed_zooms.append(val)
		val *= factor

#	var val := MAX_ZOOM
#	while val > MIN_ZOOM:
#		_precomputed_zooms.append(val)
#		val *= factor

	_precomputed_zooms.reverse()

	_max_zoom_steps = _precomputed_zooms.size()-1

signal pan_mode_entered
signal pan_mode_exited

func _process(_delta):
	if root.visible:
#	debug.print("is_panning", is_panning)
		debug.print("zoom", zoom)

#	if is_panning:
#		var mp:Vector2 = root.get_node("SubViewport").get_mouse_position()
#		var rect = root.get_global_rect()
#		var warp_pos = Vector2(mp.x, mp.y)
##		print(mp)
#		if mp.x < 0:              warp_pos.x = rect.size.x
#		elif mp.x >= rect.size.x: warp_pos.x = 0
#		if mp.y < 0:              warp_pos.y = rect.size.y
#		elif mp.y >= rect.size.y: warp_pos.y = 0
#
#		if warp_pos != mp:
#			Input.warp_mouse( rect.position + warp_pos )
##			offset += warp_pos



#func _input(event: InputEvent) -> void:
##	print(event.position)
#	if   event.is_action_pressed("left_click"):
##		ofs.x - vp_size.x
#		# to_map_x(cx) return self.worldpos - viewport_pos + cx
#
#		var vp_size:Vector2 = get_viewport().size
#		var half_vp_size:Vector2 = vp_size/2
#		var world_pos = (offset + (event.position - half_vp_size) / zoom) #* data.editor_unit_size
#		world_pos.y = -world_pos.y # Y is always UP in the views
#
#		var start:Vector3
#		var end:Vector3
#		const HUGE = 0xffffff
#
#		match root.facing:
#			data.ViewSide.FRONT:
##				printt("Front", world_pos, offset)
#				start = Vector3(world_pos.x, world_pos.y, -HUGE)
#				end = Vector3(world_pos.x, world_pos.y, HUGE)
#			data.ViewSide.RIGHT:
##				printt("Right", world_pos, offset)
#				start = Vector3(-HUGE, world_pos.y, world_pos.x)
#				end = Vector3(HUGE, world_pos.y, world_pos.x)
#			data.ViewSide.TOP:
##				printt("Top", world_pos, offset)
#				start = Vector3(world_pos.x, -HUGE, world_pos.y)
#				end = Vector3(world_pos.x, HUGE, world_pos.y)
#
#		relay.raycast_requested.emit(start, end)
#
#
#	elif event.is_action_pressed("zoom_in"): apply_zoom(-1, event.position)
#	elif event.is_action_pressed("zoom_out"):  apply_zoom(1, event.position)
#	elif event.is_action_pressed("mouse_look"):
#		is_panning = true
##		emit_signal("pan_mode_entered")
#	elif event.is_action_released("mouse_look"):
#		is_panning = false
##		emit_signal("pan_mode_exited")
#	elif event is InputEventMouseMotion and is_panning:
#		offset -= event.relative / (zoom)
##	print(is_panning)
#	update_zoom()


func apply_zoom(dir:int, mouse_pos:Vector2) -> void:
	# dir is 1 or -1

#	print(get_viewport().size, " || ", get_viewport().get_parent().size)
	var vp_size:Vector2 = get_viewport().size
	var half_vp_size:Vector2 = vp_size/2
#	var vp_size:Vector2 = get_viewport().get_parent().size

	var new_step = clamp(_curr_zoom_step+dir, 0, _max_zoom_steps)
	if new_step == _curr_zoom_step: return

	_curr_zoom_step = new_step

	var new_zoom:Vector2 = _precomputed_zooms[_curr_zoom_step] # zoom * factor
#	var new_offset := offset + (half_vp_size-mouse_pos) * (zoom - new_zoom)
	var new_offset := offset + (half_vp_size - mouse_pos) * ((zoom-new_zoom))
#		var new_offset := offset + (half_vp_size - mouse_pos) * (new_zoom-zoom)
#		var new_offset := offset + (mouse_pos) * (zoom - new_zoom)

	if data.smooth_zoom:
		var tween = create_tween() #Tween.new()
	#	add_child(tween)
		tween.connect("step_finished", _on_tween_step)
		tween.set_parallel(true)
#			tween.tween_property(self, "zoom", zoom, new_zoom, 0.05, Tween.TRANS_LINEAR, Tween.EASE_IN)
#			tween.interpolate_property(self, "offset", offset, new_offset, 0.05, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.tween_property(self, "zoom", new_zoom, 0.05)
#		tween.tween_property(self, "offset", new_offset, 0.05)
		tween.play()
	else:
		zoom = new_zoom
		offset = new_offset

#	update_stuff_that_depends_on_zoom()


func _on_tween_step(_idx:int) -> void:
	update_zoom()



func update_zoom():
	# print("%s  %s" % [_curr_zoom_step, zoom])
	grid.queue_redraw()
