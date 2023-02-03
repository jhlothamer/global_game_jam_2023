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
	$UI/VBoxContainer/ScoreCarrots/ScoreCarrot1/Sprite,
	$UI/VBoxContainer/ScoreCarrots/ScoreCarrot2/Sprite,
	$UI/VBoxContainer/ScoreCarrots/ScoreCarrot3/Sprite,
]
onready var _score_carrots_particles := [
	$UI/VBoxContainer/ScoreCarrots/ScoreCarrot1/CPUParticles2D,
	$UI/VBoxContainer/ScoreCarrots/ScoreCarrot2/CPUParticles2D,
	$UI/VBoxContainer/ScoreCarrots/ScoreCarrot3/CPUParticles2D,
]
onready var _results_lbl: Label = $UI/VBoxContainer/MarginContainer/VBoxContainer/ResultsLabel
onready var _comment_lbl: Label = $UI/VBoxContainer/MarginContainer/VBoxContainer/CommentLabel
onready var _continue_btn: Button = $UI/VBoxContainer/ButtonBar/ContinueBtn
onready var _replay_btn: Button = $UI/VBoxContainer/ButtonBar/ReplayBtn
onready var _player_vig: PlayerVignette = $PlayerVignette
onready var _ui: Control = $UI
onready var _ouch_sound: AudioStreamPlayer = $BBunnySfxOuch
onready var _win_sound: AudioStreamPlayer = $BBunnySfxWin
onready var _tween: Tween =$Tween
onready var _background: Node2D = $Background
onready var _button_bar: Control = $UI/VBoxContainer/ButtonBar

func _ready():
	hide()
	_ui.hide()
	SignalMgr.register_subscriber(self, "level_over")
	SignalMgr.register_subscriber(self, "level_completed")
	SignalMgr.register_subscriber(self, "obstacle_hit")
	SignalMgr.register_publisher(self, "level_stop")
	
	_ui.modulate = Color.transparent
	_button_bar.modulate = Color.transparent

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
	
	_animate(score)

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

func _animate(score: int) -> void:
	_button_bar.modulate = Color.transparent
	_button_bar.visible = true
	_tween.interpolate_property(_background, "position", _background.position, Vector2.ZERO, .1)
	var delay = _tween.get_runtime() + .2
	_ui.rect_scale = Vector2.ONE * .2
	_tween.interpolate_property(_ui, "modulate", Color.transparent, Color.white, .1,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, delay)
	_tween.interpolate_property(_ui, "rect_scale", _ui.rect_scale, Vector2.ONE, .4, Tween.TRANS_ELASTIC, Tween.EASE_OUT, delay)

	_tween.start()
	yield(_tween, "tween_all_completed")
	
	yield(_animate_score(score), "completed")
	
	_button_bar.rect_position.x = -512
	delay = .2
	_tween.interpolate_property(_button_bar, "modulate", Color.transparent, Color.white, .1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, delay)
	_tween.interpolate_property(_button_bar, "rect_position", _button_bar.rect_position, Vector2(0, _button_bar.rect_position.y), .4, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT, delay)

	_tween.start()
	yield(_tween, "tween_all_completed")

	

func _animate_score(score: int) -> void:
	for i in _score_carrots_sprites.size():
		if score > i:
			_score_carrots_sprites[i].modulate = Color.white
			var sprite: Sprite = _score_carrots_sprites[i]
			_tween.interpolate_property(sprite, "modulate", sprite.modulate, Color.white, .3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, .3)
			_tween.start()
			var particles: CPUParticles2D = _score_carrots_particles[i]
			particles.emitting = true
			yield(get_tree().create_timer(.7), "timeout")
			













