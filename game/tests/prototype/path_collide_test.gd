extends Node2D


onready var _line2d: Line2D = $Line2D


var _astar := AStar2D.new()



func _ready():
	for p in _line2d.points:
		_astar.add_point(_astar.get_point_count(), p)
		if _astar.get_point_count() > 1:
			_astar.connect_points(_astar.get_point_count() - 2, _astar.get_point_count() - 1)
	
	var pt1 = _astar.get_point_position(_astar.get_point_count() - 2)
	var pt2 = _astar.get_point_position(_astar.get_point_count() - 1)
	var dir = (pt2 - pt1).normalized()
	var test_pt = pt2 + dir * 18
	
	var closest_pt = _astar.get_closest_position_in_segment(test_pt)
	
	if !closest_pt.is_equal_approx(pt2):
		print("collide!")
	else:
		print("no collision")
	


