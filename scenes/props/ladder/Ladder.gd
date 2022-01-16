extends Area2D

export (int) var height = 1
export (int) var width = 3.5

func _ready():
	$CollisionShape2D.shape.extents = Vector2(width,8 * height)
	$CollisionShape2D.position = Vector2(0, -8 * height + 8)
