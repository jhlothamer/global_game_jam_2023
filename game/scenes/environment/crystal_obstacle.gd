extends Obstacle


const COL_OFFSET = [
	Vector2(0, -2),
	Vector2.ZERO,
	Vector2.ZERO,
]

const COL_COLL_RADIUS = [
	16,
]


onready var _sprite: Sprite = $Sprite


func _ready():
	_sprite.frame = randi() % (_sprite.hframes * _sprite.vframes)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
