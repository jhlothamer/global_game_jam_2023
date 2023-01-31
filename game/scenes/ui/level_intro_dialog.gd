extends Control


func _ready():
	get_tree().paused = true
	show()


func _on_PlayBtn_pressed():
	hide()
	get_tree().paused = false
