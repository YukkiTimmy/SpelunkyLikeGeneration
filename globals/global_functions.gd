extends Node

var currentSeed : int = -1

func random(minVal, maxVal) -> int:
	return randi() % maxVal + minVal


func randomBool(minVal, maxVal, minRes, maxRes) -> bool:
	var rdm = randi() % maxVal + minVal
	if rdm >= minRes and rdm <= maxRes:
		return true
	return false


func generateSeed(userSeed : String) -> int:
	if userSeed:
		currentSeed = hash(userSeed)
	else:
		randomize()
		currentSeed = randi()
		
	seed(currentSeed)
	return currentSeed
