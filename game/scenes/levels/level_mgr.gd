extends Node

var _level_scenes = [
	"res://scenes/levels/level_01.tscn",
	"res://scenes/levels/level_02.tscn",
	"res://scenes/levels/level_03.tscn",
]

var _current_level = 0


func advance_to_next_level() -> void:
	_current_level += 1
	if _current_level >= _level_scenes.size():
		_current_level = 0
		TransitionMgr.transition_to(GameConsts.SCENE_TITLE)
		return
	
	TransitionMgr.transition_to(_level_scenes[_current_level])


func reload_current_level() -> void:
	TransitionMgr.transition_to(_level_scenes[_current_level])
