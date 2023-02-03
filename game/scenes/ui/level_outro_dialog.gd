extends Control

signal level_stop()

const SCORE_MESSAGE = [
	"Collect more veggies to continue.",
	"You sqeaked by.",
	"Not bad!",
	"Good Job!",
]


enum OutroReason {
	LEVEL_COMPLETE,
	OBSTACLE_HIT,
	OOB_OR_TUNNEL,
}

onready var _score_carrots_sprites := [
	$UI/VBoxContainer/HBoxContainer/ScoreCarrot1/Sprite,
	$UI/VBoxContainer/HBoxContainer/ScoreCarrot2/Sprite,
	$UI/VBoxContainer/HBoxContainer/ScoreCarrot3/Sprite,
]
onready var _results_lbl: Label = $UI/VBoxContainer/MarginContainer/VBoxContainer/ResultsLabel
onready var _comment_lbl: Label = $UI/VBoxContainer/MarginContainer/VBoxContainer/CommentLabel
onready var _continue_btn: Button = $UI/VBoxContainer/HBoxContainer2/VBoxContainer/ContinueBtn
onready var _replay_btn: Button = $UI/VBoxContainer/HBoxContainer2/VBoxContainer/ReplayBtn
onready var _player_vig: PlayerVignette = $PlayerVignette
onready var _ui: Control = $UI
onready var _ouch_sound: AudioStreamPlayer = $BBunnySfxOuch
onready var _win_sound: AudioStreamPlayer = $BBunnySfxWin


func _ready():
	hide()
	_ui.hide()
	SignalMgr.register_subscriber(self, "level_over")
	SignalMgr.register_subscriber(self, "level_completed")
	SignalMgr.register_subscriber(self, "obstacle_hit")
	SignalMgr.register_publisher(self, "level_stop")

func _on_level_over(level_over_reason:int ) -> void:
	var msg := ""
	if level_over_reason == TunnelLead.LevelOverReason.OOB:
		msg = "Gotta' stay in bounds!"
	elif  level_over_reason == TunnelLead.LevelOverReason.TUNNEL:
		msg = "Tunnel full of rocks can't be crossed!"
	_show_dialog(false, msg)
	

func _on_obstacle_hit(obstacle) -> void:
	var msg := "Watch out for those crystals!"
	if obstacle is MovingObstacle:
		msg = "We told you bettles were meanies!"
	_show_dialog(false, msg)


func _on_level_completed():
	_show_dialog(true, "All veggies collected!  Yeah!!")

func _show_dialog(win: bool, comment_msg: String):

	emit_signal("level_stop")

	if win:
		_win_sound.play()
	else:
		_ouch_sound.play()
	
	show()
	get_tree().paused = true
	
	var score = _get_score()
	

	_results_lbl.text = SCORE_MESSAGE[score]
	_comment_lbl.text = comment_msg
	
	
	yield(_player_vig.outro_vignette(), "completed")
	
	_ui.show()
	
	_animate_score(score)

	var can_continue = score >= 1
	if !can_continue:
		_replay_btn.grab_focus()
#		_replay_btn.grab_click_focus()
		_continue_btn.hide()
	else:
		_continue_btn.grab_focus()
#		_continue_btn.grab_click_focus()


func _get_score() -> int:
	var score_mgr: ScoreMgr = ServiceMgr.get_service(ScoreMgr)
	if !score_mgr:
		printerr("LevelOutroDlg: cannot get ScoreMgr service")
		return 0
	var percent_complete = score_mgr.get_items_collected_percentage()
	if percent_complete == 1.0:
		return 3
	if percent_complete >= .5:
		return 2
	if percent_complete >= .25:
		return 1
	return 0


func _on_ContinueBtn_pressed():
	LevelMgr.advance_to_next_level()


func _on_ReplayBtn_pressed():
	LevelMgr.reload_current_level()


func _animate_score(score: int) -> void:
	print("score was %d" % score)
	for i in _score_carrots_sprites.size():
		if score > i:
			_score_carrots_sprites[i].modulate = Color.white
			print(_score_carrots_sprites[i].get_path())



