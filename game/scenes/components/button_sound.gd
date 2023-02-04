class_name ButtonSound
extends Node

class CallbackData:
	var func_ref: FuncRef
	var binds: Array
	func _init(fr: FuncRef, b: Array) -> void:
		func_ref = fr
		binds = b
	func invoke() -> void:
		func_ref.call_funcv(binds)

enum SoundType {
	MENU,
	PLAY1,
	PLAY2
	RANDOM,
}

export (SoundType) var sound_type: int

var _sounds := []

var _call_backs := []

func _ready():
	
	for c in get_children():
		if c is AudioStreamPlayer:
			_sounds.append(c)
	
	var btn: Button = get_parent()
	
	var arr = btn.get_signal_connection_list("pressed")
	for i in arr:
		var callback = funcref(i.target, i.method)
		_call_backs.append(CallbackData.new(callback, i.binds))
		btn.disconnect("pressed", i.target, i.method)
	
	if OK != btn.connect("pressed", self, "_on_btn_pressed"):
		printerr("ButtonSound: can't connect to button's pressed signal")


func _on_btn_pressed():
	print("ButtonSound: !!")

	

	var sound: AudioStreamPlayer
	if sound_type == SoundType.RANDOM:
		sound = _sounds[randi() % _sounds.size()]
	else:
		sound = _sounds[sound_type]
	sound.play()
	yield(sound,"finished")
	for i in _call_backs:
		i.invoke()
