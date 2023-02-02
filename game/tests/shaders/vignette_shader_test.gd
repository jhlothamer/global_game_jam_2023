extends Node2D

onready var _tween: Tween = $Tween
onready var _sprite:AnimatedSprite = $AnimatedSprite
onready var _cr:ColorRect = $ColorRect


func _ready():
#	_intro_vignette()
	_outro_vignette()
	


func _intro_vignette():
	var player_pos = _sprite.position / get_viewport_rect().size

	_cr.material.set_shader_param("player_position", player_pos)
	_cr.material.set_shader_param("SCALE", .2)
	
	_tween.interpolate_property(_cr.material, "shader_param/SCALE", 0.2, 6.4, 1.0, Tween.TRANS_LINEAR,Tween.EASE_IN_OUT, 4.0)

	_tween.start()


func _outro_vignette():
	var player_pos = _sprite.position / get_viewport_rect().size

	_cr.material.set_shader_param("player_position", player_pos)
	_cr.material.set_shader_param("SCALE", 6.4)
	
	_tween.interpolate_property(_cr.material, "shader_param/SCALE", 6.4, 0.2, 1.0, Tween.TRANS_LINEAR,Tween.EASE_IN_OUT, 4.0)

	_tween.start()
