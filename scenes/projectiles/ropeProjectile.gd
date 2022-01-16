extends Area2D

const SPEED = 200
var dir := Vector2.UP

onready var origin : Vector2 = position

func _ready():
	position.x = int(round(position.x)) / 16 * 16 + 8
	origin.x = position.x
	
func _physics_process(delta):
	if position.distance_to(origin) < 16 * 6:
		position += (transform.y * SPEED * delta) * dir.y
	else:
		var scene = load("res://scenes/projectiles/rope.tscn")
		var instance = scene.instance()
		instance.position = position
		instance.start = position
		instance.end = origin
		get_parent().add_child(instance)
		queue_free()

func _on_proejctile_body_entered(body):
	if body.name == "TileMap":
		var relPos = (position - body.global_position + dir * 16) / 16
		var scene = load("res://scenes/projectiles/rope.tscn")
		var instance = scene.instance()
		instance.start = position
		instance.end = origin
		instance.position = position + Vector2(0,7)
		get_parent().add_child(instance)
		queue_free()
