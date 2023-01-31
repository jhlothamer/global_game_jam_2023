class_name ScoreMgr
extends Label


signal level_completed()


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
	if _items_collected_count == _total_number_of_items:
		emit_signal("level_completed")


func get_items_collected_percentage() -> float:
	if _total_number_of_items == 0:
		return .0
	return float(_items_collected_count) / float(_total_number_of_items)


func _get_number_of_items_callback(number_of_items) -> void:
	_total_number_of_items = number_of_items
	_update_label()
