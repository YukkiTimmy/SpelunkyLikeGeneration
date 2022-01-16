extends Node2D

var generationReady : bool = true

var player : KinematicBody2D = null

func _process(delta):
	if Input.is_action_just_pressed("R") && Input.is_action_pressed("ui_strg") && generationReady == true:
		generationReady = false
		for n in get_children():
			if n.get_class() != "CanvasModulate" && n.get_class() != "Label":
				n.queue_free()
		
		var scene = load("res://scenes/generator/RandomLevelGeneration.tscn")
		var instance = scene.instance()
		
		$Label.text = str("SEED:", GF.currentSeed)
		
		self.add_child(instance)
		
		yield(get_tree().create_timer(0.5), "timeout")
		
		
		var playerScene = load("res://scenes/player/Player.tscn")
		var playerInstance = playerScene.instance()
		playerInstance.position = Vector2((instance.startPosition+1)*256 - 128,176/2)
		self.add_child(playerInstance)
		
		generationReady = true
		
	
func _on_RandomLevelGeneration_mapDrawn():
	var scene = load("res://scenes/player/player.tscn")
	var instance = scene.instance()
	player = instance
	instance.position = Vector2(($RandomLevelGeneration.startPosition+1)*256 - 128,176/2)
	self.add_child(instance)



func random(minVal, maxVal):
	var rng = RandomNumberGenerator.new()

	return rng.randi_range(minVal, maxVal)
	
