extends Node2D


export (String) var currentSeed = ""


func _ready() -> void:

	
	var seedToUse : int = -1
	
	if currentSeed:
		seedToUse = hash(currentSeed)
	else:
		print(seedToUse)
		seedToUse = randi()
	
	seed(seedToUse)
	
	print("SEED: ", seedToUse)
