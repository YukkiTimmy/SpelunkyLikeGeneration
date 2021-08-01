extends Node2D

onready var cam := $Camera2D

export (int) var WIDTH = 5
export (int) var HEIGHT = 5

var generationReady : bool = false

func _ready():
	# setting up the camera
	cam.zoom.x = WIDTH
	cam.zoom.y = HEIGHT
	
	cam.position.x = float(WIDTH) / 2 * 256
	cam.position.y = float(HEIGHT) / 2 * 176
	
	
	
	# instancing a new map
	var scene = load("res://RandomGeneration.tscn")
	var instance = scene.instance()
	
	# setting the maps WIDTH and HEIGHT
	instance.WIDTH = WIDTH
	instance.HEIGHT = HEIGHT
	
	self.add_child(instance)
	
	yield(get_tree().create_timer(1), "timeout")
	
	# enabeling the generation
	generationReady = true
	
func _process(delta):
	# buy pressing space or enter you can generate a new map
	if Input.is_action_pressed("ui_accept") && generationReady == true:
		# blocking the generation
		generationReady = false
		
		# clear the old map
		for n in get_children():
			if n.is_in_group("map"):
				n.queue_free()
		
		# instancing a new map
		var scene = load("res://RandomGeneration.tscn")
		var instance = scene.instance()

		# setting the maps WIDTH and HEIGHT
		instance.WIDTH = WIDTH
		instance.HEIGHT = HEIGHT

		self.add_child(instance)
		
		yield(get_tree().create_timer(1), "timeout")
		
		# enabeling the generation
		generationReady = true
