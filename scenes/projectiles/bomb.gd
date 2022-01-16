extends Area2D

func _ready():
	yield(get_tree().create_timer(3), "timeout")
	
	var dir = Vector2.DOWN
	
	for i in [-1,0,1]:
		for j in [-1,0,1]:
			dir = Vector2(i,j)
			var scene = load("res://scenes/projectiles/bombRadius.tscn")
			var instance = scene.instance()
			if i == 0 || j == 0:
				instance.position = position + dir * 16
			else:
				instance.position = position + dir * 10
			get_parent().add_child(instance)

	queue_free()
