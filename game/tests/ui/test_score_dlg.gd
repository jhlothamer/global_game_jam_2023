extends Level

signal level_completed()


func _enter_tree():
	ServiceMgr.register_service(Level, self)


func _ready():
	SignalMgr.register_publisher(self, "level_completed")


func _on_TestDlg_pressed():
	emit_signal("level_completed")
