class_name ScoreMgr
extends Label


signal level_completed()


export var item_collected_scale := Vector2.ONE * 1.2


onready var _item_collected_sound: AudioStreamPlayer = $BBunnySfxPowerUp
onready var _tween: Tween = $Tween


var _items_collected_count := 0
var _total_number_of_items := 0


func _enter_tree():
	ServiceMgr.register_service(get_script(), self)


func _ready():
	SignalMgr.register_subscriber(self, "item_collected")
	SignalMgr.register_publisher(self, "level_completed")
	var lvl: Level = ServiceMgr.get_service(Level)
	if !lvl:
		printerr("ScoreMgr: can't get Level service.")
		return
	lvl.get_number_of_items_async(funcref(self, "_get_number_of_items_callback"))


func _update_label() -> void:
	text = "%d / %d" % [_items_collected_count, _total_number_of_items]


func _on_item_collected():
	_items_collected_count += 1
	_update_label()
	_item_collected_sound.play(.1)
	_animate()
	if _items_collected_count == _total_number_of_items:
#		if _item_collected_sound.playing:
#			yield(_item_collected_sound, "finished")
		emit_signal("level_completed")


func get_items_collected_percentage() -> float:
	if _total_number_of_items == 0:
		return .0
	return float(_items_collected_count) / float(_total_number_of_items)


func _get_number_of_items_callback(number_of_items) -> void:
	_total_number_of_items = number_of_items
	_update_label()


func _animate() -> void:
	_tween.interpolate_property(self, "rect_scale", Vector2.ONE, item_collected_scale, .1)
	_tween.interpolate_property(self, "rect_scale", item_collected_scale, Vector2.ONE, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, .1)
	_tween.start()
