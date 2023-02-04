extends Control

signal title_screen_loaded()

onready var _exit_btn:Button = $ButtonsMarginContainer/VBoxContainer/ExitBtn

func _ready():
	SignalMgr.register_publisher(self, "title_screen_loaded")
	if OS.get_name() == "HTML5":
		_exit_btn.visible = false
	emit_signal("title_screen_loaded")


func _on_ExitBtn_pressed():
	get_tree().quit()
