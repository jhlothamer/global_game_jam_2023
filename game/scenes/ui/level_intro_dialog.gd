extends Control

signal level_start()

onready var _play_btn: Button = $VBoxContainer/CenterContainer/PlayBtn
onready var _instruct_lbl: RichTextLabel = $VBoxContainer/MarginContainer/InstructionsLabel
onready var _player_vig = $PlayerVignette
onready var _ui = $VBoxContainer

func _ready():
	SignalMgr.register_publisher(self, "level_start")
	get_tree().paused = true
	show()
	_play_btn.grab_focus()
	var lvl: Level = ServiceMgr.get_service(Level)
	if !lvl:
		printerr("LevelIntroDialog: could not get level service")
		return
	_instruct_lbl.bbcode_text = lvl.intro_message_bbs


func _on_PlayBtn_pressed():
	_ui.hide()
	yield(_player_vig.intro_vignette(), "completed")
	hide()
	get_tree().paused = false
	emit_signal("level_start")
