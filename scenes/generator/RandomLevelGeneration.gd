extends Node2D

export (float) var drawDelay = 0.01
export (float) var generateDelay = 0.001

export (String) var userSeed = ""


const WIDTH = 5
const HEIGHT = 5

const ROOM_WIDTH = 256
const ROOM_HEIGHT = 176

var currentSeed : int = -1

var map := []
var startPosition : int = 0

enum EVENTS {DEFAULT, PITS}
var event = EVENTS.DEFAULT


signal mapGenerated
signal extraRoomsPlaced
signal mapDrawn 


func _ready() -> void:
	currentSeed = GF.generateSeed(userSeed)
	
	generatePath()

	yield(self, "mapGenerated")
	print("Generating done\n")
	
	placeExtraRooms()
	
	yield(self, "extraRoomsPlaced")
	print("Extra Rooms Placed\n")
	
	printMap()
	
	yield(self, "mapDrawn")
	print("Drawing Done")
	
	placeObjects()
	
		
func generatePath() -> void:
	# S: start
	# 0: fill
	# 1: left, right
	# 2: left, right, bottom
	# 3: left, right, top
	# 4: left, right, top, bottom
	# 7: pit top
	# 8: pit center
	# 9: pit bottom
	# E: end
	
	map = []
	
	# fill map with 0
	for x in range(WIDTH):
		map.append([])
		for y in HEIGHT:
			map[x].append("0")
	
	var posX : int = 0
	var posY : int = 0
	
	# random start position in first row
	startPosition = random(0,WIDTH-1)
	map[0][startPosition] = "S"
	posX = startPosition
	
	# choosing next room, at least one step per row
	var nextRoom : int = 0 # 1 left, 2 right, 3 bottom
	var movedOnce : bool = false
	
	var finished : bool = false
	
	
	while !finished:
		yield(get_tree().create_timer(generateDelay), "timeout")
		# First move
		if !movedOnce:
			# Check if you are in the Corners
			if posX > 0 && posX < WIDTH - 1:
				# if not move left or right
				nextRoom = random(1,2)
				match nextRoom:
					1:
						posX -= 1
					2:
						posX += 1
			elif posX == 0:
				posX += 1
			elif posX == WIDTH -1:
				posX -= 1
			
			map[posY][posX] = "1"
			movedOnce = true
		
		# second, third... step
		elif movedOnce && posY < HEIGHT - 1:
			# if you are in a corner you must go down
			if posX == 0 || posX == WIDTH - 1:
				if posY > 0 && map[posY-1][posX] == "2" || posY > 0 && map[posY-1][posX] == "4":
					map[posY][posX] = "4"
				else:
					map[posY][posX] = "2"
				
				posY += 1
				map[posY][posX] = "3"
				movedOnce = false
			
			# else you are in the center and could do a step
			else:
				# to the left (1) or down (2)
				var way : int = random(1,2)
				
				# sideways
				if way == 1:
					# check if left is free
					if map[posY][posX-1] == "0":
						posX -= 1
						map[posY][posX] = "1"
					# else right is free
					else:
						posX += 1
						map[posY][posX] = "1"
				
				#down
				else:
					if posY > 0 && map[posY-1][posX] == "2" || posY > 0 && map[posY-1][posX] == "4":
						map[posY][posX] = "4"
					else:
						map[posY][posX] = "2"
				
					posY += 1
					map[posY][posX] = "3"
					movedOnce = false
		
		# last step
		else:
			if posX > 0 && posY < WIDTH - 1:
				nextRoom = random(1,2)
				match nextRoom:
					1:
						posX -= 1
					2:
						posX += 1
				
				map[posY][posX] = "1"
			
			else:
				map[posY][posX] = "E"
				finished = true
	
	# print the map out 
	for d in HEIGHT:
		print(map[d])
	
	emit_signal("mapGenerated")

	
func placeExtraRooms():
	var randomEvent = GF.random(1,10)
	if randomEvent == 1 or randomEvent == 2:
		print("PITS MAY OCCURE")
		event = EVENTS.PITS
		
	match event:
		EVENTS.DEFAULT:
			pass
			
		EVENTS.PITS:
			for y in HEIGHT:
				for x in WIDTH:
					yield(get_tree().create_timer(generateDelay), "timeout")
					# if you are in the first layer the pit can be 2-4 rooms deep
					if map[y][x] == "0" && y < 2:
						var chance : int = random(1,3)
						if chance == 1:
							if map[y+1][x] == "0" && map[y+2][x] == "0" && map[y+3][x] == "0":
								if random(1,10) == 1:
									map[y][x] = "7"
									map[y+1][x] = "8"
									map[y+2][x] = "8"
									map[y+3][x] = "9"
						
						elif chance == 2:
							if map[y+1][x] == "0" && map[y+2][x] == "0":
								if random(1,10) == 1:
									map[y][x] = "7"
									map[y+1][x] = "8"
									map[y+2][x] = "9"

						else:
							if map[y+1][x] == "0":
								if random(1,10) == 1:
									map[y][x] = "7"
									map[y+1][x] = "9"

					
					# if you are in the second layer the pit can be 2-3 rooms deep
					elif map[y][x] == "0" && y < 3:
						if random(1,2) == 1:
							if map[y+1][x] == "0" && map[y+2][x] == "0":
								if random(1,15) == 1:
									map[y][x] = "7"
									map[y+1][x] = "8"
									map[y+2][x] = "9"
									print("drei übereinander ", x, " ", y)
						else:
							if map[y+1][x] == "0":
								if random(1,15) == 1:
									map[y][x] = "7"
									map[y+1][x] = "9"
									print("zwei übereinander ", x, " ", y)
					
					# if you are in the third layer the pit can only be 2 rooms deep
					elif map[y][x] == "0" && y == 3:
						if map[y+1][x] == "0":
							if random(1,20) == 1:
								map[y][x] = "7"
								map[y+1][x] = "9"
								print("zwei übereinander ", x, " ", y)
		
		
	#random fill
	for y in HEIGHT:
		for x in WIDTH:
			yield(get_tree().create_timer(generateDelay), "timeout")
			if map[y][x] == "0":
				var fillRooms = random(1,10)
				if fillRooms <= 3:
					match fillRooms:
						1:
							map[y][x] = "1"
						2:
							if y < 4:
								if map[y+1][x] == "2":
									map[y][x] = "2"
									map[y+1][x] = "4"
							else:
								map[y][x] = "2"
						3:
							if y > 0:
								if map[y-1][x] == "3":
									map[y][x] = "3"
									map[y-1][x] = "4"
							else:
								map[y][x] = "3"

	
	
	for d in HEIGHT:
		print(map[d])
	
	emit_signal("extraRoomsPlaced")

	
func printMap() -> void:
	for y in HEIGHT:
		for x in WIDTH:
			yield(get_tree().create_timer(drawDelay), "timeout")
			var pathName = ""
			
			# loop through the map and place random rooms of the type given
			match map[y][x]:
				"S":
					var startRooms : int = random(1,3)
					pathName = str("res://scenes/rooms/start/start", startRooms ,".tscn")
				"E":
					var endRooms : int = random(1,1)
					pathName = str("res://scenes/rooms/end/end", endRooms ,".tscn")
				"1":
					var leftRighRooms : int = random(1,5)
					pathName = str("res://scenes/rooms/left_right/left_right", leftRighRooms ,".tscn")
				"2":
					var leftRightBottomRooms : int = random(1,5)
					pathName = str("res://scenes/rooms/left_right_bottom/left_right_bottom", leftRightBottomRooms ,".tscn")
				"3":
					var leftRightTopRooms : int = random(1,5)
					pathName = str("res://scenes/rooms/left_right_top/left_right_top", leftRightTopRooms ,".tscn")
				"4":
					var leftRightTopBottomRooms : int = random(1,1)
					pathName = str("res://scenes/rooms/left_right_top_bottom/left_right_top_bottom", leftRightTopBottomRooms ,".tscn")
				"7":
					var pitTopRooms : int = random(1,1)
					pathName = str("res://scenes/rooms/pit_top/pit_top", pitTopRooms, ".tscn")
				"8":
					var pitCenterRooms : int = random(1,1)
					pathName = str("res://scenes/rooms/pit_center/pit_center", pitCenterRooms, ".tscn")
				"9":
					var pitBottomRooms : int = random(1,1)
					pathName = str("res://scenes/rooms/pit_bottom/pit_bottom", pitBottomRooms, ".tscn")
				
				"0":
					var fillRooms : int = random(1,1)
					pathName = str("res://scenes/rooms/fill/fill", fillRooms, ".tscn")
			
			placeMap(pathName, x * ROOM_WIDTH, y * ROOM_HEIGHT)
	
	# create border 
	for n in $rooms.get_children():
		if n.get_node("TileMap").global_position.y == 0:
			for x in range(-1,17):
				n.get_node("TileMap").set_cellv(Vector2(x,0), 0)
		
		if n.get_node("TileMap").global_position.y == 176 * (HEIGHT - 1):
			for x in range(-1,17):
				n.get_node("TileMap").set_cellv(Vector2(x,10), 0)
		
		if n.get_node("TileMap").global_position.x == 0:
			for y in 11:
				n.get_node("TileMap").set_cellv(Vector2(0,y), 0)
		
		if n.get_node("TileMap").global_position.x == 256 * (WIDTH - 1):
			for y in 11:
				n.get_node("TileMap").set_cellv(Vector2(15,y), 0)
	
	emit_signal("mapDrawn")


func placeObjects() -> void:
	# ore placement
	for n in $rooms.get_children():
		for y in 16:
			for x in 11:
				var map = n.get_node("TileMap")
				if map.get_cellv(Vector2(x,y)) == 0:
					var chance = random(1,20)
					match chance:
						# gold
						1:
							map.set_cellv(Vector2(x,y), 1)
						
						# rocks
						2,3:
							map.set_cellv(Vector2(x,y), 2)
						

	print("Placing Ores done")

	
func placeMap(path, offsetX, offsetY) -> void:
	var scene = load(path)
	var instance = scene.instance()
	$rooms.add_child(instance)
	instance.position = Vector2(offsetX, offsetY)


func random(minVal, maxVal):
	return randi() % maxVal + minVal
