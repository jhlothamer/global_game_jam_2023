extends Node2D

export var cave_in_line_2d: NodePath
export var tunnel_lead: NodePath
export var delay_seconds := 1.0

onready var _cave_in_line_2d: Line2D = get_node(cave_in_line_2d)
onready var _tunnel_lead: TunnelLead = get_node(tunnel_lead)
onready var _delay_timer: Timer = $DelayTimer
onready var _particles:CPUParticles2D = $Swivel/CPUParticles2D
onready var _swivel: Node2D = $Swivel


var _speed := 0.0
var _prev_direction := Vector2.INF

func _ready():
	set_physics_process(false)
	if !_cave_in_line_2d:
		printerr("CaveIn: no cave-in line 2d set")
		return
	if !_tunnel_lead:
		printerr("CaveIn: no tunnel lead set")
		return
	_speed = _tunnel_lead.speed
	_prev_direction = _tunnel_lead.initial_direction
	position = _tunnel_lead.position
	_delay_timer.start(delay_seconds)
	SignalMgr.register_subscriber(self, "level_stop")


func _on_DelayTimer_timeout():
	_cave_in_line_2d.points = PoolVector2Array([position, position])
	set_physics_process(true)
	_particles.emitting = true


func _physics_process(delta):
	var direction = _tunnel_lead.direction_queue.pop_front()
	if _prev_direction != direction:
		var pos = position
		var points = _cave_in_line_2d.points
		points.push_back(pos)
		_cave_in_line_2d.points = points
		_prev_direction = direction
		_swivel.rotation = direction.angle()

	position += direction * _speed
	var pos = position
	var points = _cave_in_line_2d.points
	points.set(_cave_in_line_2d.points.size() - 1, pos)
	_cave_in_line_2d.points = points


func _on_level_stop():
	_particles.emitting = false
