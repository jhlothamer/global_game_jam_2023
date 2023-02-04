tool
extends CloneConfig



func config_cloned_node(cloned_node: Node) -> void:
	pass
	if !cloned_node is Sprite:
		return
	var s: Sprite = cloned_node
	s.frame = randi() % (s.hframes * s.vframes)
