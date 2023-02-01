class_name Level
extends Node2D

export (int, 1, 3) var number_of_starts_to_continue := 1
export (String, MULTILINE) var intro_message_bbs := "[center]Good Luck![/center]"

onready var _items:Node2D = $Items


var _get_number_of_items_callbacks = []


func _enter_tree():
	_register_service()


func _ready():
	var number_of_items = _items.get_child_count()
	for callback in _get_number_of_items_callbacks:
		callback.call_func(number_of_items)


func _register_service():
	ServiceMgr.register_service(get_script(), self)


func get_number_of_items_async(callback: FuncRef) -> void:
	if _items:
		callback.call_func(_items.get_child_count())
		return
	_get_number_of_items_callbacks.append(callback)

