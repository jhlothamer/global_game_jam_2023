extends Control


onready var _play_btn: Button = $MarginContainer/VBoxContainer/HBoxContainer/PlayBtn


func _ready():
	_play_btn.grab_focus()


func _on_PlayBtn_pressed():
	LevelMgr.advance_to_next_level()
