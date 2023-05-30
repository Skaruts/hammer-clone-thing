extends Node
# autoloaded script

enum ToolMode {
	SELECT,
	BRUSH,
	ENTITY,
	VERTEX,
	EDGE,
	FACE,
}
var curr_tool_mode:ToolMode = ToolMode.SELECT


const HUGE = 0xffffff


var editor_unit_size := 1.0/100.0  # 1 Godot Unit / 64 = 1 Editor Unit
var default_zoom_step:int = 30
var zoom_factor:float = 1.2
var smooth_zoom:bool = true

var _curr_edited_map_index:int = -1


var color_brush_selected := Color("ff4d4d")
#var color_brush_selected := Color("acff00")
var color_brush_selected_behind := Color(1,1,1,0.5)
var color_brush          := Color("b3e0ff")
var color_entity_brush   := Color("3bb0ff")
var color_entity         := Color("ff9e4a")









var _maps:Array[MapDocument]
#var grid_size :=

var _map_id := -1
func _next_map_id() -> int:
	_map_id += 1
	return _map_id

func create_map() -> MapDocumentBrush:
	var map = MapDocumentBrush.new("new_map_" + str(_next_map_id()))
	_maps.append(map)
	_curr_edited_map_index = _maps.size()-1
	return map


func get_current_map() -> MapDocumentBrush:
	return _maps[_curr_edited_map_index]




func v3toeu(gu_coords:Vector3) -> Vector3:
	return gu_coords * data.editor_unit_size

func v3togu(eu_coords:Vector3) -> Vector3:
	return eu_coords / data.editor_unit_size

func v2toeu(gu_coords:Vector2) -> Vector2:
	return gu_coords * data.editor_unit_size

func v2togu(eu_coords:Vector2) -> Vector2:
	return eu_coords / data.editor_unit_size


func to_eu(gu_coords):
	return gu_coords * data.editor_unit_size

func to_gu(eu_coords):
	return eu_coords / data.editor_unit_size
