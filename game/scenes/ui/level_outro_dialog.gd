extends Control


onready var _score_carrots := [
	$VBoxContainer/HBoxContainer/ScoreCarrot1,
	$VBoxContainer/HBoxContainer/ScoreCarrot2,
	$VBoxContainer/HBoxContainer/ScoreCarrot3,
]
onready var _results_lbl: Label = $VBoxContainer/ResultsLabel
onready var _continue_btn: Button = $VBoxContainer/ContinueBtn


var _can_continue := false

func _ready():
	hide()
	SignalMgr.register_subscriber(self, "level_over", "_on_level_completed")
	SignalMgr.register_subscriber(self, "level_completed")
	SignalMgr.register_subscriber(self, "obstacle_hit", "_on_level_completed")


func _on_level_completed():
	var score_mgr: ScoreMgr = ServiceMgr.get_service(ScoreMgr)
	var percent_complete = score_mgr.get_items_collected_percentage()

	show()
	get_tree().paused = true
	_continue_btn.grab_focus()
	
	if percent_complete < 1.0:
		_score_carrots[2].modulate = Color.black
	if percent_complete < .5:
		_score_carrots[1].modulate = Color.black
	if percent_complete < .25:
		_score_carrots[0].modulate = Color.black
	
	_can_continue = percent_complete >= .25
	if !_can_continue:
		_continue_btn.text = "Replay Level"
		_results_lbl.text = "Collect more veggies to continue!"

func _on_ContinueBtn_pressed():
	if _can_continue:
		LevelMgr.advance_to_next_level()
		return
	LevelMgr.reload_current_level()
	
