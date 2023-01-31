extends Node2D

signal game_over()

export var speed := 1.5
export var line_2d:NodePath
export var turn_speed := 180.0


onready var _line_2d:Line2D = get_node(line_2d)
onready var _turn_speed := deg2rad(turn_speed)


var _direction := Vector2.RIGHT
var _a_star := AStar2D.new()


func _ready():
	if !_line_2d:
		printerr("TunnelLead: no line 2d set.")
		set_physics_process(false)
		return
	_line_2d.points = PoolVector2Array([position, position])
	_a_star.add_point(0, position)
	_a_star.add_point(1, position)
	_a_star.connect_points(0, 1)
	SignalMgr.register_publisher(self, "game_over")


func _get_input_direction() -> Vector2:
	var v = Vector2.ZERO
	v.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	v.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	return v


func _collided_with_path() -> bool:
	var test_pt = _direction * _line_2d.width/2.0 + position
	
	var closest_pt = _a_star.get_closest_position_in_segment(test_pt)
	var last_pt = _a_star.get_point_position(_a_star.get_point_count() - 1)
	
	return !closest_pt.is_equal_approx(last_pt)



func _physics_process(delta):
	var turn_change := 0.0
	
	var input_dir = _get_input_direction()
	
	if input_dir != Vector2.ZERO:
		var pos = position
		var points = _line_2d.points
		points.push_back(pos)
		_line_2d.points = points
		_a_star.add_point(_a_star.get_point_count(), position)
		_a_star.connect_points(_a_star.get_point_count() - 2, _a_star.get_point_count() - 1)
		var input_dir_angle = input_dir.angle()
		var dir_angle = _direction.angle()
		var change_angle = lerp_angle(dir_angle, input_dir_angle, 1.0)
		var delta_angle = _turn_speed * delta
		change_angle = clamp(change_angle, dir_angle - delta_angle, dir_angle + delta_angle)
		_direction = _direction.rotated(change_angle - dir_angle)
	
	position += _direction * speed
	var pos = position
	var points = _line_2d.points
	points.set(_line_2d.points.size() - 1, pos)
	_line_2d.points = points
	_a_star.set_point_position(_a_star.get_point_count() - 1, pos)
	
	if _collided_with_path():
		emit_signal("game_over")
		set_physics_process(false)



