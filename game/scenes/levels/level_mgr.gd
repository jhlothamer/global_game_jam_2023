extends Node

var _level_scenes = [
	"res://scenes/levels/level_01.tscn",
	"res://scenes/levels/level_02.tscn",
	"res://scenes/levels/level_03.tscn",
	"res://scenes/levels/level_04.tscn",
	"res://scenes/levels/level_05.tscn",
	"res://scenes/levels/level_06.tscn",
	"res://scenes/levels/level_07.tscn",
#	"res://scenes/levels/level_08.tscn",
]

var _level_scores = []

var _current_level = -1


func _ready():
	SignalMgr.register_subscriber(self, "title_screen_loaded")
	SignalMgr.register_subscriber(self, "level_scored")
	
	for i in _level_scenes.size():
		_level_scores.append(0)
	
	#_level_scores = FileUtil.load_json_data(GameConsts.FILE_PATH_LEVEL_SCORE, _level_scores)


func advance_to_next_level() -> void:
	_current_level += 1
	if _current_level >= _level_scenes.size():
		_current_level = 0
		SoundTracks.update_pitch_scale(1.0)
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


func get_level_score(level_number: int) -> int:
	return _level_scores[level_number]


func is_level_last_unpassed(level_number: int) -> bool:
	return _level_scores[level_number] == 0 and (level_number == 0 or _level_scores[level_number - 1] > 0)


func _on_title_screen_loaded() -> void:
	_current_level = -1


func _on_level_scored(score: int) -> void:
	if _level_scores.size() < _current_level + 1:
		while _level_scores.size() < _current_level + 1:
			_level_scores.add(0)
	_level_scores[_current_level] = score
	#FileUtil.save_json_data(GameConsts.FILE_PATH_LEVEL_SCORE, _level_scores)




