class_name BrushUtils extends Node

# replace these with those in editor_data
static func gu_to_eu(gu_coords:Vector3) -> Vector3:
	return gu_coords * data.editor_unit_size

static func eu_to_gu(eu_coords:Vector3) -> Vector3:
	return eu_coords / data.editor_unit_size


static func sort_brushes_by_edge_proximity_front_facing(brushes:Array, real_position:Vector3) -> Array[Brush]:
	var sorted_brushes:Array[Brush] = []

	var dists = []
	for b in brushes:
		var closest:float = 0xffffffff
		for e in b.edges:
			if e.v1.x == e.v2.x and e.v1.y == e.v2.y: continue

			var edge_dists = [
				abs(e.v1.x-real_position.x), abs(e.v2.x-real_position.x),
				abs(e.v1.y-real_position.y), abs(e.v2.y-real_position.y),
			]

			for d in edge_dists:
				if d < closest:
					closest = d
		dists.append([closest, b])

	dists.sort_custom(func(a:Array, b:Array) -> bool: return a[0] < b[0])

	for d in dists:
		sorted_brushes.append(d[1])

	return sorted_brushes

static func sort_brushes_by_edge_proximity_side_facing(brushes:Array, real_position:Vector3) -> Array[Brush]:
	var sorted_brushes:Array[Brush] = []

	var dists = []
	for b in brushes:
		var closest:float = 0xffffffff
		for e in b.edges:
			if e.v1.z == e.v2.z and e.v1.y == e.v2.y: continue

			var edge_dists = [
				abs(e.v1.z-real_position.z), abs(e.v2.z-real_position.z),
				abs(e.v1.y-real_position.y), abs(e.v2.y-real_position.y),
			]

			for d in edge_dists:
				if d < closest:
					closest = d
		dists.append([closest, b])

	dists.sort_custom(func(a:Array, b:Array) -> bool: return a[0] < b[0])

	for d in dists:
		sorted_brushes.append(d[1])

	return sorted_brushes

static func sort_brushes_by_edge_proximity_top_facing(brushes:Array, real_position:Vector3) -> Array[Brush]:
	var sorted_brushes:Array[Brush] = []

	var dists = []
	for b in brushes:
		var closest:float = 0xffffffff
		for e in b.edges:
			if e.v1.x == e.v2.x and e.v1.z == e.v2.z: continue

			var edge_dists = [
				abs(e.v1.x-real_position.x), abs(e.v2.x-real_position.x),
				abs(e.v1.z-real_position.z), abs(e.v2.z-real_position.z),
			]
#			printt(b, edge_dists)
			for d in edge_dists:
				if d < closest:
					closest = d
		dists.append([closest, b])
#		printt(b, closest)
#		print("--------------")
	dists.sort_custom(func(a:Array, b:Array) -> bool: return a[0] < b[0])
#	print(dists)
	for d in dists:
		sorted_brushes.append(d[1])
#	print("=======================")
	return sorted_brushes



#static func check_edge_dist_from_point_front(point:Vector3, a:Brush, b:Brush) -> bool:
#	var a_closest:float = INF
#	var b_closest:float = INF
#
#	for e in a.edges:
#		if e.v1.x == e.v2.x and e.v1.y == e.v2.y: continue
#		var dists = [
#			abs(e.v1.x-point.x), abs(e.v2.x-point.x),
#			abs(e.v1.y-point.y), abs(e.v2.y-point.y),
#		]
#		for d in dists:
#			if d < a_closest:
#				a_closest = d
#
#	for e in b.edges:
#		if e.v1.x == e.v2.x and e.v1.y == e.v2.y: continue
#		var dists = [
#			abs(e.v1.x-point.x), abs(e.v2.x-point.x),
#			abs(e.v1.y-point.y), abs(e.v2.y-point.y),
#		]
#		for d in dists:
#			if d < b_closest:
#				b_closest = d
#
#	return a_closest < b_closest
#
#
#static func check_edge_dist_from_point_side(point:Vector3, a:Brush, b:Brush) -> bool:
#	var a_closest:float = INF
#	var b_closest:float = INF
#
#	for e in a.edges:
#		if e.v1.z == e.v2.z and e.v1.y == e.v2.y: continue
#		var dists = [
#			abs(e.v1.z-point.z), abs(e.v2.z-point.z),
#			abs(e.v1.y-point.y), abs(e.v2.y-point.y),
#		]
#		for d in dists:
#			if d < a_closest:
#				a_closest = d
#
#	for e in b.edges:
#		if e.v1.z == e.v2.z and e.v1.y == e.v2.y: continue
#		var dists = [
#			abs(e.v1.z-point.z), abs(e.v2.z-point.z),
#			abs(e.v1.y-point.y), abs(e.v2.y-point.y),
#		]
#		for d in dists:
#			if d < b_closest:
#				b_closest = d
#
#	return a_closest < b_closest
#
#
#static func check_edge_dist_from_point_top(point:Vector3, a:Brush, b:Brush) -> bool:
#	var a_closest:float = 0xffffffff
#	var b_closest:float = 0xffffffff
#
#	for e in a.edges:
#		if e.v1.x == e.v2.x and e.v1.z == e.v2.z: continue
#
#		var dists = [
#			abs(e.v1.x-point.x), abs(e.v2.x-point.x),
#			abs(e.v1.z-point.z), abs(e.v2.z-point.z),
#		]
#		for d in dists:
#			if d < a_closest:
#				a_closest = d
#
#	for e in b.edges:
#		if e.v1.x == e.v2.x and e.v1.z == e.v2.z: continue
#
#		var dists = [
#			abs(e.v1.x-point.x), abs(e.v2.x-point.x),
#			abs(e.v1.z-point.z), abs(e.v2.z-point.z),
#		]
#		for d in dists:
#			if d < b_closest:
#				b_closest = d
#
#	return a_closest <= b_closest
