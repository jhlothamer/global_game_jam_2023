extends "res://scenes/environment/obstacle.gd"

export var speed = 10.0


var _direction := Vector2.RIGHT


func _ready():
	_direction = _direction.rotated(rand_range(-PI, PI))


func _physics_process(delta):
	position += _direction * speed * delta
