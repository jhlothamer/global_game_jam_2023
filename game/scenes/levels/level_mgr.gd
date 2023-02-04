extends Node

var _level_scenes = [
	"res://scenes/levels/level_01.tscn",
	"res://scenes/levels/level_02.tscn",
	"res://scenes/levels/level_03.tscn",
	"res://scenes/levels/level_04.tscn",
	"res://scenes/levels/level_05.tscn",
	"res://scenes/levels/level_06.tscn",
	"res://scenes/levels/level_07.tscn",
]

var _current_level = -1


func advance_to_next_level() -> void:
	_current_level += 1
	if _current_level >= _level_scenes.size():
		_current_level = 0
		TransitionMgr.transition_to(GameConsts.SCENE_THANKS4PLAYING)
		return
	
	TransitionMgr.transition_to(_level_scenes[_current_level])


func reload_current_level() -> void:
	if _current_level == -1:
		var current_scene = get_tree().get_current_scene()
		var temp = _level_scenes.find(current_scene.filename)
		if temp > -1:
			_current_level = temp
	TransitionMgr.transition_to(_level_scenes[_current_level])

func get_level_number() -> int:
	return _current_level + 1
