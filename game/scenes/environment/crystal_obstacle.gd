tool
extends Obstacle


const COL_OFFSET = [
	Vector2(-1, -4),
	Vector2(2, -2),
	Vector2(0, -1),
	
]

const COL_COLL_EXTENTS = [
	Vector2(7,9),
	Vector2(8,14),
	Vector2(11,15),
]

enum CrystalSize {
	SMALL,
	MEDIUM,
	LARGE,
	RANDOM
}

export (CrystalSize) var crystal_size: int setget _set_crystal_size


onready var _sprite: Sprite = $Sprite
onready var _coll: RectangleShape2D = $Area2D/CollisionShape2D.shape


func _ready():
	_update_for_size()


func _set_crystal_size(value: int) -> void:
	crystal_size = value
	if !_sprite:
		return
	_update_for_size()


func _update_for_size() -> void:
	var temp = crystal_size
	if temp == CrystalSize.RANDOM:
		temp =randi() % 3
	_sprite.frame_coords.x = temp
	_sprite.frame_coords.y = randi() % (_sprite.vframes)
	_sprite.offset = COL_OFFSET[temp]
	_coll.extents = COL_COLL_EXTENTS[temp]
