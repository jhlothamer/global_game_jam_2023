extends Control

onready var _play_btn: Button = $VBoxContainer/CenterContainer/PlayBtn

func _ready():
	get_tree().paused = true
	show()
	_play_btn.grab_focus()


func _on_PlayBtn_pressed():
	hide()
	get_tree().paused = false
