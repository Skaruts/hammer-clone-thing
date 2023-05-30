class_name DrawTool3DBackLines extends DrawTool3DMesh

#var _face_alpha := 0.25

#var color:Color:
#	get: return line_color
#	set(color):
#		line_color = color

func _init(thickness:float, color:Color, _unshaded:=true) -> void:
	on_top = true
	transparent = true
	line_color = color
	line_thickness = thickness
	unshaded = _unshaded

#	render_priority = -1
