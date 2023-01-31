extends Node2D

signal item_collected()


func _ready():
	SignalMgr.register_publisher(self, "item_collected")


func _on_Area2D_area_entered(area: Area2D):
	if area.is_in_group("player"):
		print("item collected")
		emit_signal("item_collected")
		queue_free()
