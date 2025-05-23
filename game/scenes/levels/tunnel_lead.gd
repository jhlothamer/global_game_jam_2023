class_name TunnelLead
extends Node2D

signal level_over(level_over_reason)

enum LevelOverReason {
	NONE,
	OOB,
	TUNNEL,
}

export var speed := 1.5
export var line_2d:NodePath
export var turn_speed := 180.0
export var initial_direction := Vector2.RIGHT
export var out_of_bounds_ref_rect:NodePath
export var do_flip := false


var direction_queue := []


onready var _line_2d:Line2D = get_node(line_2d)
onready var _out_of_bounds_ref_rect:ReferenceRect = get_node(out_of_bounds_ref_rect)
onready var _turn_speed := deg2rad(turn_speed)
onready var _anim_sprite: AnimatedSprite = $AnimatedSprite
onready var _tween: Tween = $Tween
onready var _dig_particles: CPUParticles2D = $AnimatedSprite/CPUParticles2D
onready var _dig_sound: AudioStreamPlayer = $BBunnySfxDig01


var _direction := Vector2.RIGHT
var _a_star := AStar2D.new()
var _out_of_bounds_rect := Rect2(Vector2.ZERO, Vector2.INF)


func _enter_tree():
	ServiceMgr.register_service(get_script(), self)


func _ready():
	if !_line_2d:
		printerr("TunnelLead: no line 2d set.")
		set_physics_process(false)
		return
	if !_out_of_bounds_ref_rect:
		printerr("TunnelLead: no out of bounds ref rect set.")
		set_physics_process(false)
		return

	SignalMgr.register_subscriber(self, "level_start")
	SignalMgr.register_publisher(self, "level_over")
	SignalMgr.register_subscriber(self, "level_stop")
	SignalMgr.register_subscriber(self, "item_collected")
	SignalMgr.register_subscriber(self, "obstacle_hit")

	_direction = initial_direction.normalized()
	_anim_sprite.rotation = _direction.angle()
	_flip_bunny()

	_line_2d.points = PoolVector2Array([position, position])

	_a_star.add_point(0, position)
	_a_star.add_point(1, position)
	_a_star.connect_points(0, 1)
	
	_out_of_bounds_rect = Rect2(_out_of_bounds_ref_rect.rect_position, _out_of_bounds_ref_rect.rect_size)



func _get_input_direction() -> Vector2:
	var v = Vector2.ZERO
	v.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	v.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	return v


func _collided_or_out_of_bounds() -> int:
	var test_pt = _direction * _line_2d.width/2.0 + position
	
	if !_out_of_bounds_rect.has_point(test_pt):
		return LevelOverReason.OOB
	
	var closest_pt = _a_star.get_closest_position_in_segment(test_pt)
	var last_pt = _a_star.get_point_position(_a_star.get_point_count() - 1)
	
	if !closest_pt.is_equal_approx(last_pt):
		return LevelOverReason.TUNNEL
	
	return LevelOverReason.NONE



func _flip_bunny() -> void:
	if !do_flip:
		return
	if is_zero_approx(_direction.x):
		return
	var scale_y = -1.0 if _direction.x < 0 else 1.0
	if sign(scale_y) == sign(_anim_sprite.scale.y):
		return
	if _tween.is_active():
		_tween.stop_all()
	var target_scale = Vector2(1, scale_y)
	_tween.interpolate_property(_anim_sprite, "scale", _anim_sprite.scale, target_scale, .2)
	_tween.start()


func _on_level_start():
	_dig_particles.emitting = true
	_dig_sound.play()


func _on_level_stop():
	_dig_particles.emitting = false
	_dig_sound.stop()


func _physics_process(delta):
	
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
		_anim_sprite.rotation = _direction.angle()
		_flip_bunny()
	
	position += _direction * speed
	direction_queue.push_back(_direction)
	var pos = position
	var points = _line_2d.points
	points.set(_line_2d.points.size() - 1, pos)
	_line_2d.points = points
	_a_star.set_point_position(_a_star.get_point_count() - 1, pos)
	
	var level_over_reason = _collided_or_out_of_bounds()
	if level_over_reason != LevelOverReason.NONE:
		_anim_sprite.play("ouch")
		_anim_sprite.connect("frame_changed", self, "_on_AnimatedSprite_frame_changed")
		_anim_sprite.pause_mode = Node.PAUSE_MODE_PROCESS
		_dig_particles.emitting = false
		_dig_sound.stop()
		emit_signal("level_over", level_over_reason)
		set_physics_process(false)

func _on_item_collected() -> void:
	_anim_sprite.play("yum")

func _on_AnimatedSprite_animation_finished():
	if _anim_sprite.animation == "yum":
		_anim_sprite.play("default")

func _on_AnimatedSprite_frame_changed():
	if _anim_sprite.animation != "ouch":
		return
	if _anim_sprite.frame >= 4:
		_anim_sprite.rotation = 0.0


func _on_obstacle_hit(_obstacle) -> void:
	_anim_sprite.play("ouch")
	_anim_sprite.connect("frame_changed", self, "_on_AnimatedSprite_frame_changed")
	_anim_sprite.pause_mode = Node.PAUSE_MODE_PROCESS
	_dig_particles.emitting = false
	_dig_sound.stop()
	set_physics_process(false)
