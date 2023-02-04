extends Node

onready var _mgr := $SoundTrackMgr
onready var _tween := $Tween

func update_pitch_scale(pitch_scale: float) -> void:
	pass
	var current_stream := _get_playing_stream(_mgr)
	if !current_stream:
		return
	current_stream.pitch_scale = pitch_scale
	
#	_tween.interpolate_property(current_stream, "pitch_scale", current_stream.pitch_scale, pitch_scale, .2)
#	_tween.start()


func _get_playing_stream(n: Node) -> AudioStreamPlayer:
	if n is AudioStreamPlayer and n.playing:
		return n as AudioStreamPlayer
	for c in n.get_children():
		var result = _get_playing_stream(c)
		if result:
			return result
	return null
