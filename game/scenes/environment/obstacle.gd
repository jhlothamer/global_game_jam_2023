class_name Obstacle
extends Node2D


signal obstacle_hit(obstacle)


func _ready():
	SignalMgr.register_publisher(self, "obstacle_hit")


func _on_Area2D_area_entered(area: Area2D):
	if area.is_in_group("player"):
		emit_signal("obstacle_hit", self)

