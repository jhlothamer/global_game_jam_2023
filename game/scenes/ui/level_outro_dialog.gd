extends Control

signal level_stop()

enum OutroReason {
	LEVEL_COMPLETE,
	OBSTACLE_HIT,
	OOB_OR_TUNNEL,
}

onready var _score_carrots := [
	$VBoxContainer/HBoxContainer/ScoreCarrot1,
	$VBoxContainer/HBoxContainer/ScoreCarrot2,
	$VBoxContainer/HBoxContainer/ScoreCarrot3,
]
onready var _results_lbl: Label = $VBoxContainer/MarginContainer/VBoxContainer/ResultsLabel
onready var _comment_lbl: Label = $VBoxContainer/MarginContainer/VBoxContainer/CommentLabel
onready var _continue_btn: Button = $VBoxContainer/HBoxContainer2/VBoxContainer/ContinueBtn
onready var _replay_btn: Button = $VBoxContainer/HBoxContainer2/VBoxContainer/ReplayBtn
onready var _player_vig: PlayerVignette = $PlayerVignette
onready var _ui: VBoxContainer = $VBoxContainer
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
	var msg := "Watch out for those rocks!"
	if obstacle is MovingObstacle:
		msg = "We told you bettles were meanies!"
	_show_dialog(false, msg)


func _on_level_completed():
	_show_dialog(true, "All veggies collected!  Yeah!!")

func _show_dialog(win: bool, comment_msg: String):
	var score_mgr: ScoreMgr = ServiceMgr.get_service(ScoreMgr)
	var percent_complete = score_mgr.get_items_collected_percentage()

	emit_signal("level_stop")

	if win:
		_win_sound.play()
	else:
		_ouch_sound.play()
	
	show()
	get_tree().paused = true
	
	
	var message = "Good Job!"
	# got 2 carrots
	if percent_complete < 1.0:
		_score_carrots[2].modulate = Color.black
		message = "Not bad!"
	# got 1 carrot
	if percent_complete < .5:
		_score_carrots[1].modulate = Color.black
		message = "You sqeaked by."
	# got 0 carrots
	if percent_complete < .25:
		message = "Collect more veggies to continue."
		_score_carrots[0].modulate = Color.black

	_results_lbl.text = message
	_comment_lbl.text = comment_msg
	
	
	yield(_player_vig.outro_vignette(), "completed")
	
	_ui.show()

	var can_continue = percent_complete >= .25
	if !can_continue:
		_replay_btn.grab_focus()
#		_replay_btn.grab_click_focus()
		_continue_btn.hide()
	else:
		_continue_btn.grab_focus()
#		_continue_btn.grab_click_focus()


func _on_ContinueBtn_pressed():
	LevelMgr.advance_to_next_level()


func _on_ReplayBtn_pressed():
	LevelMgr.reload_current_level()
