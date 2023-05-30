extends Node

signal grid_size_changed

signal selection_ray_cast_request(start:Vector3, end:Vector3)
signal selection_shape_cast_request(start:Vector3, end:Vector3)

signal view_2d_redraw_request
signal view_2d_update_gizmos_request

signal view_2d_mouse_pressed(axis:int, position:Vector3)
signal view_2d_mouse_released(axis:int, position:Vector3)
signal view_2d_mouse_dragged(axis:int, position:Vector2, relative:Vector2)
#signal view_2d_mouse_moved


signal view_3d_mouse_moved(camera:Camera3D, position:Vector2)#, from:Vector3, dir:Vector3)
signal view_3d_mouse_pressed(camera:Camera3D, position:Vector2)
signal view_3d_mouse_released(camera:Camera3D, position:Vector2)
signal view_3d_mouse_dragged(camera:Camera3D, position:Vector2, relative:Vector2)
