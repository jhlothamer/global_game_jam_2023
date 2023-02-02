class_name PlayerVignette
extends ColorRect


onready var _tween: Tween = $Tween


func _get_player_position() -> Vector2:
	
	var player: TunnelLead = ServiceMgr.get_service(TunnelLead)
	if !player:
		return Vector2.ZERO
	
	return player.position / get_viewport_rect().size


func intro_vignette():
	var player_pos = _get_player_position()

	material.set_shader_param("player_position", player_pos)
	material.set_shader_param("SCALE", .2)
	
	_tween.interpolate_property(material, "shader_param/SCALE", 0.2, 6.4, 1.0)

	_tween.start()

	yield(_tween, "tween_all_completed")


func outro_vignette():
	var player_pos = _get_player_position()

	material.set_shader_param("player_position", player_pos)
	material.set_shader_param("SCALE", 6.4)
	
	_tween.interpolate_property(material, "shader_param/SCALE", 6.4, 0.2, 1.0)

	_tween.start()

	yield(_tween, "tween_all_completed")
	yield(get_tree().create_timer(1.0), "timeout")
	material.set_shader_param("SCALE", 0.0)

