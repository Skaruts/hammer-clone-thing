class_name DrawTool3DCanvas extends Control

# Tool for 2D drawing from 3D coordinates


var cam:Camera3D
var lines := []
var polylines := []
var colored_polylines := []
var multilines := []
# var rects := []
# var circles := []
# var polygons := []
# var col_polygons := []
# var primitives := []

func _ready() -> void:
	cam = get_viewport().get_camera_3d()


func _draw() -> void:
	_draw_lines()
	_draw_polylines()
	_draw_colored_polylines()
	_draw_multilines()
	# _draw_rects()
	# _draw_circles()
	# _draw_polygons()
	# _draw_col_polygons()
	# _draw_primitives()


func clear() -> void:
	# _commands.clear()
	lines = []
	polylines = []
	multilines = []
	# rects = []
	# circles = []
	# polygons = []
	# col_polygons = []
	# primitives = []


func unprojected_line(verts:Array):
	var points := []
	for i in range(0, verts.size(), 2):
		var p1 = verts[i]
		var p2 = verts[i+1]
		var is_p1_behind := cam.is_position_behind(p1)
		var is_p2_behind := cam.is_position_behind(p2)
		if is_p1_behind and is_p2_behind:
			continue

		var near = cam.get_frustum()[0]
		if is_p1_behind:   p1 = near.intersects_segment(p2, p1)
		elif is_p2_behind: p2 = near.intersects_segment(p1, p2)

		points.append( cam.unproject_position(p1) )
		points.append( cam.unproject_position(p2) )
	return points

func unprojected_polyline(verts:Array):
	var points := []
	var clipped_verts = Geometry3D.clip_polygon(verts, cam.get_frustum()[0])
	for v in clipped_verts:
		points.append( cam.unproject_position(v) )
	return points


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#		private
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
func _draw_lines() -> void:
#	var up1; var up2
	for l in lines:
		var upts = unprojected_line([l[0], l[1]])
		# if cam.is_position_behind(l[0]) or cam.is_position_behind(l[1]):
			# continue
		# up1 = cam.unproject_position(l[0])
		# up2 = cam.unproject_position(l[1])
		if not upts.size(): continue
		draw_line(upts[0], upts[1], l[2], l[3], l[4])

func _draw_polylines() -> void:
	var upts
	for pl in polylines:
		upts = unprojected_polyline(pl[0])
		if not upts.size(): continue
		draw_polyline(upts, pl[1], pl[2], pl[3])


func _draw_colored_polylines() -> void:
	var upts
	for pl in colored_polylines:
		upts = unprojected_polyline(pl[0])
		if not upts.size(): continue
		draw_polyline_colors(upts, pl[1], pl[2], pl[3])

func _draw_multilines() -> void:
	var upts := []
	for ml in multilines:
		upts = unprojected_line(ml[0])
		if not upts.size(): continue
		draw_multiline(upts, ml[1], ml[2])










#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#		public
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

func line(from: Vector3, to: Vector3, color: Color, width: float = 1.0, antialiased: bool = false) -> void:
	lines.append([from, to, color, width, antialiased])
	queue_redraw()

# add lines from array of lines [ [p1, p2], [p1, p2], ...])
func batch_lines(points:Array, colors:Array, widths:Array, antialiased:Array) -> void:
	for i in points.size():
		var p = points[i]
		lines.append([p[0], p[1], colors[i], widths[i], antialiased[i]])

# add lines in a contiguous array [ p1, p2, p3, p4, p5, p6, ... ]
# number of points must be even
func batch_clines(points:Array, color:Color, width: float = 1.0, antialiased: bool = false ) -> void:
	for i in range(1, points.size(), 2):
		lines.append([points[i-1], points[i], color, width, antialiased])

func polyline(points: Array, color: Color, width: float = 1.0, antialiased: bool = false ) -> void:
	polylines.append([points, color, width, antialiased])

func multiline(points: Array, color: Color, width: float = 1.0, antialiased: bool = false ) -> void:
	multilines.append([points, color, width, antialiased])

func polyline_colors(points:Array, colors:Array, width: float = 1.0, antialiased: bool = false) -> void:
	colored_polylines.append([points, colors, width, antialiased])

# func primitive(points: PoolVector2Array, colors: PoolColorArray, uvs: PoolVector2Array, texture: Texture = null, width: float = 1.0, normal_map: Texture = null )
# 	primitives.append([points, colors, uvs, texture, width, normal_map])

# func rect(rect: Rect2, color: Color, filled: bool = true, width: float = 1.0, antialiased: bool = false ) -> void:
# 	rects.append([rect, color, filled, width, antialiased])

# func circle(position: Vector2, radius: float, color: Color) -> void:
# 	circles.append([position, radius, color])

# func polygon(points: Array, colors: PoolColorArray, antialiased: bool = false ) -> void:
# 	polygons.append([points, colors, antialiased])

# func colored_polygon(points: Array, color: Color, antialiased: bool = false) -> void:
# 	col_polygons.append([points, color, antialiased])



# draw_arc(center: Vector2, radius: float, start_angle: float, end_angle: float, point_count: int, color: Color, width: float = 1.0, antialiased: bool = false)
# draw_char(font: Font, position: Vector2, char: String, next: String, modulate: Color = Color( 1, 1, 1, 1 ))
# draw_circle(position: Vector2, radius: float, color: Color)
# draw_colored_polygon(points: PoolVector2Array, color: Color, uvs: PoolVector2Array = PoolVector2Array(), texture: Texture = null, normal_map: Texture = null, antialiased: bool = false)
# draw_line(from: Vector2, to: Vector2, color: Color, width: float = 1.0, antialiased: bool = false)
# draw_mesh(mesh: Mesh, texture: Texture, normal_map: Texture = null, transform: Transform2D = Transform2D( 1, 0, 0, 1, 0, 0 ), modulate: Color = Color( 1, 1, 1, 1 ) )
# draw_multiline(points: PoolVector2Array, color: Color, width: float = 1.0, antialiased: bool = false )
# draw_multiline_colors(points: PoolVector2Array, colors: PoolColorArray, width: float = 1.0, antialiased: bool = false )
# draw_multimesh(multimesh: MultiMesh, texture: Texture, normal_map: Texture = null )
# draw_polygon(points: PoolVector2Array, colors: PoolColorArray, uvs: PoolVector2Array = PoolVector2Array(), texture: Texture = null, normal_map: Texture = null, antialiased: bool = false )
# draw_polyline(points: PoolVector2Array, color: Color, width: float = 1.0, antialiased: bool = false )

# draw_primitive(points: PoolVector2Array, colors: PoolColorArray, uvs: PoolVector2Array, texture: Texture = null, width: float = 1.0, normal_map: Texture = null )
# draw_rect(rect: Rect2, color: Color, filled: bool = true, width: float = 1.0, antialiased: bool = false )
# draw_set_transform(position: Vector2, rotation: float, scale: Vector2 )
# draw_set_transform_matrix(xform: Transform2D )
# draw_string(font: Font, position: Vector2, text: String, modulate: Color = Color( 1, 1, 1, 1 ), clip_w: int = -1 )
# draw_style_box(style_box: StyleBox, rect: Rect2 )
# draw_texture(texture: Texture, position: Vector2, modulate: Color = Color( 1, 1, 1, 1 ), normal_map: Texture = null )
# draw_texture_rect(texture: Texture, rect: Rect2, tile: bool, modulate: Color = Color( 1, 1, 1, 1 ), transpose: bool = false, normal_map: Texture = null )
# draw_texture_rect_region(texture: Texture, rect: Rect2, src_rect: Rect2, modulate: Color = Color( 1, 1, 1, 1

