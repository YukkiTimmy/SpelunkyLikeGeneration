extends Node2D

export (String, FILE, "*.tscn") var enemy_path = "res://scenes/entitis/enemies/Snake/snake.tscn"
export (int, 1, 100) var probability = 50

func _ready():
	$ColorRect.visible = true
	if GF.randomBool(1,100,1,probability):
		var scene = load(enemy_path)
		var instance = scene.instance()
		add_child(instance)
	
