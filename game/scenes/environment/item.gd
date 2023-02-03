extends Node2D

const SPARKLE_CLASS = preload("res://scenes/environment/sparkle.tscn")

signal item_collected()


enum ItemType {
	RANDOM,
	BEET,
	CARROT,
	ONION,
	TURNIP
}


const ITEM_TO_ANIM = {
	ItemType.BEET: "beet",
	ItemType.CARROT: "carrot",
	ItemType.ONION: "onion",
	ItemType.TURNIP: "turnip",
}


export (ItemType) var item_type: int


onready var _anim_sprite: AnimatedSprite = $AnimatedSprite



func _ready():
	SignalMgr.register_publisher(self, "item_collected")
	
	var temp := item_type
	if temp == ItemType.RANDOM:
		pass
		temp = randi() % ITEM_TO_ANIM.size() + 1
	
	_anim_sprite.play(ITEM_TO_ANIM[temp])


func _on_Area2D_area_entered(area: Area2D):
	if area.is_in_group("player"):
		emit_signal("item_collected")
		visible = false
		_sparkle()
		queue_free()

func _sparkle():
	var sparkle = SPARKLE_CLASS.instance()
	get_parent().add_child(sparkle)
	sparkle.position = position


