extends Node2D


onready var _tween: Tween = $Tween
onready var _titles := [
	$BbunnyTitle1,
	$BbunnyTitle2,
	$BbunnyTitle3,
]
onready var _ends := [
	$StartsStops/EndPos1.position,
	$StartsStops/EndPos2.position,
	$StartsStops/EndPos3.position,
]
onready var _delays := [
	0,
	.9,
	1.8
]

var _animated := false

func _animate() -> void:
	if _animated:
		return
	_animated = true
#	var t1 = _titles[0]
#	_tween.interpolate_property(_titles[0], "position", t1.position, _ends[0], .4, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
#	_tween.start()
	var delay_between = .5
	var delay := 0.0
	for i in _titles.size():
		_tween.interpolate_property(_titles[i], "position", _titles[i].position, _ends[i], .4, Tween.TRANS_BOUNCE, Tween.EASE_OUT, _delays[i])
		delay += _tween.get_runtime() + delay_between
	
	_tween.start()


func _input(event):
	if event is InputEventKey:
		var ek: InputEventKey = event
		if ek.scancode == KEY_SPACE:
			_animate()
