extends Control


onready var _score_carrots := [
	$VBoxContainer/HBoxContainer/ScoreCarrot1,
	$VBoxContainer/HBoxContainer/ScoreCarrot2,
	$VBoxContainer/HBoxContainer/ScoreCarrot3,
]
onready var _results_lbl: Label = $VBoxContainer/MarginContainer/ResultsLabel
onready var _continue_btn: Button = $VBoxContainer/HBoxContainer2/VBoxContainer/ContinueBtn


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
	
	
	var message = "Good Job!"
	# got 2 carrots
	if percent_complete < 1.0:
		_score_carrots[2].modulate = Color.black
		message = "Not bad!"
	# got 1 carrot
	if percent_complete < .5:
		_score_carrots[1].modulate = Color.black
		message = "You did it!"
	# got 0 carrots
	if percent_complete < .25:
		message = "Collect more veggies to continue."
		_score_carrots[0].modulate = Color.black

	_results_lbl.text = message
	
	_can_continue = percent_complete >= .25
	if !_can_continue:
		_continue_btn.text = "Replay Level"

func _on_ContinueBtn_pressed():
	if _can_continue:
		LevelMgr.advance_to_next_level()
		return
	LevelMgr.reload_current_level()
	
