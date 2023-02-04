class_name Level
extends Node2D

export (String, MULTILINE) var intro_message_bbs := "[center]Good Luck![/center]"
export var sound_track_pitch_scale := 1.0

onready var _items:Node2D = $Items
onready var _oob_ref_rect: ReferenceRect = $OutOfBoundsReferenceRect

var _get_number_of_items_callbacks = []
var _get_out_of_bounds_rect_callbacks = []


func _enter_tree():
	_register_service()


func _ready():
	SoundTracks.update_pitch_scale(sound_track_pitch_scale)
	var number_of_items = _items.get_child_count()
	for callback in _get_number_of_items_callbacks:
		callback.call_func(number_of_items)
	for callback in _get_out_of_bounds_rect_callbacks:
		callback.call_func(_get_out_of_bounds_rect())


func _register_service():
	ServiceMgr.register_service(get_script(), self)


func get_number_of_items_async(callback: FuncRef) -> void:
	if _items:
		callback.call_func(_items.get_child_count())
		return
	_get_number_of_items_callbacks.append(callback)


func _get_out_of_bounds_rect() -> Rect2:
	return Rect2(_oob_ref_rect.rect_position, _oob_ref_rect.rect_size)


func get_out_of_bounds_rect_async(callback: FuncRef) -> void:
	if _oob_ref_rect:
		callback.call_func(_get_out_of_bounds_rect())
		return
	_get_out_of_bounds_rect_callbacks.append(callback)
