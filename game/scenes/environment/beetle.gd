extends MovingObstacle


const ROTATION_OFFSET = .5*PI


export var wiggle_angle_max := 10.0
export var wiggle_speed := 10.0


onready var _swivel: Node2D = $Swivel
onready var _anim_sprite: AnimatedSprite = $Swivel/AnimatedSprite
onready var _tween: Tween = $Tween
onready var _wiggle_angle_max := deg2rad(wiggle_angle_max)

var _timer := 0.0


func _ready():
	_swivel.rotation = _direction.angle() + ROTATION_OFFSET


func _direction_updated() -> void:
	var a = wrapf(_direction.angle() + ROTATION_OFFSET, -PI, PI)
	a = lerp_angle(_swivel.rotation + ROTATION_OFFSET, a, 1.0)
	_tween.interpolate_property(_swivel, "rotation", _swivel.rotation, a, .4)
	_tween.start()


func _physics_process(delta):
	_anim_sprite.rotation = cos(_timer * wiggle_speed) * _wiggle_angle_max
	_timer += delta
