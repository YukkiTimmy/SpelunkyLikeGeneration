extends Area2D

var start : Vector2 = Vector2.ZERO
var end : Vector2 = Vector2.ZERO


func _ready():
	print(position)
	$rope.points[1].y = (end.y - start.y)

	$CollisionShape2D.shape.extents.y = (end.y - start.y) / 2
	$CollisionShape2D.position.y += $CollisionShape2D.shape.extents.y
