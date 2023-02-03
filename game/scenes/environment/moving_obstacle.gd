class_name MovingObstacle
extends "res://scenes/environment/obstacle.gd"

export var speed = 10.0
export var oob_reflection_max = 60.0

onready var _oob_reflection_max = deg2rad(oob_reflection_max)


var _direction := Vector2.RIGHT
var _oob_rect: Rect2
var _corners := []
var _oob_center := Vector2.ZERO


func _ready():
	_direction = _direction.rotated(rand_range(-PI, PI))
	var lvl: Level = ServiceMgr.get_service(Level)
	if !lvl:
		printerr("MovingObstacle: couldn't get level service")
		set_physics_process(false)
		return
	lvl.get_out_of_bounds_rect_async(funcref(self, "_get_out_of_bounds_rect_callback"))


func _get_out_of_bounds_rect_callback(oob_rect: Rect2) -> void:
	_oob_rect = oob_rect
	_oob_rect = _oob_rect.grow(-20.0)
	_oob_center = _oob_rect.position + .5 * _oob_rect.size
	_corners = [
		_oob_rect.position, 
		_oob_rect.end,
		Vector2(_oob_rect.position.x, _oob_rect.end.y),
		Vector2(_oob_rect.end.x, _oob_rect.position.y),
	]


func _direction_updated() -> void:
	pass


func _physics_process(delta):
	position += _direction * speed * delta
	if _oob_rect.has_point(position):
		return
	var corner_distances_sq = {}
	
	var pos = position
	for pt in _corners:
		corner_distances_sq[pos.distance_squared_to(pt)] = pt
	
	var sorted_distances = corner_distances_sq.keys()
	sorted_distances.sort()
	var pt1 = corner_distances_sq[sorted_distances[0]]
	var pt2 = corner_distances_sq[sorted_distances[1]]
	var side_center = (pt1 + pt2) / 2.0
	var v:Vector2 = _oob_center - side_center
	_direction = v.rotated(rand_range(-_oob_reflection_max, _oob_reflection_max)).normalized()
	_direction_updated()
