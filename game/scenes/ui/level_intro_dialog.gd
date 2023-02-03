extends Control

signal level_start()

onready var _play_btn: Button = $VBoxContainer/CenterContainer/PlayBtn
onready var _instruct_lbl: RichTextLabel = $VBoxContainer/MarginContainer/InstructionsLabel
onready var _player_vig = $PlayerVignette
onready var _ui = $VBoxContainer
onready var _background: Node2D = $Background

onready var _background_start: Vector2 = $StartsNStops/BackgroundStart.position
var _background_middle := Vector2.ZERO
onready var _background_end: Vector2 = $StartsNStops/BackgroundEnd.position

onready var _ui_start: Vector2 = $StartsNStops/UIStart.position
onready var _ui_middle: Vector2 = $StartsNStops/UIMiddle.position
onready var _ui_end: Vector2 = $StartsNStops/UIEnd.position

onready var _tween: Tween = $Tween


func _ready():
	SignalMgr.register_publisher(self, "level_start")
	get_tree().paused = true
	_ui.modulate = Color.transparent
	show()
	_play_btn.grab_focus()
	var lvl: Level = ServiceMgr.get_service(Level)
	if !lvl:
		printerr("LevelIntroDialog: could not get level service")
		return
	_instruct_lbl.bbcode_text = lvl.intro_message_bbs
	
	_animate_in()


func _on_PlayBtn_pressed():
	yield(_animate_out(), "completed")
	yield(_player_vig.intro_vignette(), "completed")
	hide()
	get_tree().paused = false
	emit_signal("level_start")

func _animate_in():
	yield(self, "ready")
	_background.position = _background_start
	_ui.rect_position = _ui_start
	print(_ui_start)
	
	_tween.interpolate_property(_background, "position", _background_start, _background_middle, .4, Tween.TRANS_LINEAR, Tween.EASE_IN, .2)
	var delay = _tween.get_runtime() + .2
	_tween.interpolate_property(_ui, "rect_position", _ui_start, _ui_middle, .4, Tween.TRANS_BOUNCE, Tween.EASE_OUT, delay)
	_tween.interpolate_property(_ui, "modulate", Color.transparent, Color.white, .4, Tween.TRANS_LINEAR, Tween.EASE_IN, delay)

	_tween.start()


func _animate_out():
	
	_tween.interpolate_property(_ui, "rect_position", _ui_middle, _ui_end, .5, Tween.TRANS_LINEAR, Tween.EASE_IN, .2)
	#_tween.interpolate_property(_ui, "modulate", Color.white, Color.transparent, .4, Tween.TRANS_LINEAR, Tween.EASE_IN, .2)
	var delay = _tween.get_runtime() + .2
	_tween.interpolate_property(_background, "position", _background_middle, _background_end, .4, Tween.TRANS_LINEAR, Tween.EASE_IN, delay)

	_tween.start()
	
	yield(_tween, "tween_all_completed")





