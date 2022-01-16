extends Area2D

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	queue_free()

func _on_bombRadius_body_shape_entered(body_id, body, body_shape, area_shape):
	if body.name == "TileMap":
		var relPos = (position - body.global_position) / 16
		body.set_cellv(relPos, -1)
		queue_free()
