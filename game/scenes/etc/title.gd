extends Control

onready var _exit_btn:Button = $ButtonsMarginContainer/VBoxContainer/ExitBtn

func _ready():
	if OS.get_name() == "HTML5":
		_exit_btn.visible = false


func _on_ExitBtn_pressed():
	get_tree().quit()
