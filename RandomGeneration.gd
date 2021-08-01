extends Node2D

onready var background = $Background

export (int) var WIDTH = 5
export (int) var HEIGHT = 5

const ROOM_WIDTH = 256
const ROOM_HEIGHT = 176

var map := []
var startPosition : int = 0

signal mapGenerated
signal extraRoomsPlaced
signal mapDrawn 

func _ready():
	background.rect_size = Vector2(WIDTH * ROOM_WIDTH , HEIGHT * ROOM_HEIGHT)
	
	# generate the main path
	gerneratePath()
	
	# wait for the generation to finish
	yield(self, "mapGenerated")
	print("Generating done\n")
	
	# generate extra rooms
	placeExtraRooms()
	
	# wait for the extraRooms to be placed
	yield(self, "extraRoomsPlaced")
	print("Extra Rooms Placed\n")
	
	#print the Map onscreen
	printMap()
	
	# wait for the map to be printed
	yield(self, "mapDrawn")
	print("Drawing Done")
	
	print("Done")
	
func gerneratePath():
	# S: start
	# 0: fill
	# 1: left, right
	# 2: left, right, bottom
	# 3: left, right, top
	# 4: left, right, top, bottom
	# E: end
	
	#clear the map
	map = []
	
	# fill the map with 0's
	for y in range(HEIGHT):
		map.append([])
		for x in WIDTH:
			map[y].append("0")



	var posX : int = 0
	var posY : int = 0


	# select a random position in the first row
	startPosition = random(0,WIDTH-1)
	# mark it with an S
	map[0][startPosition] = "S"
	# set our current x-position to the startPosition 
	posX = startPosition


	# variable between 1 to 3, to store the direction of the next room
	var nextRoom : int = 0 # 1 left, 2 right, 3 bottom
	# Implementing at least one move per row, to make generation more interesting and preventing long drops
	var movedOnce : bool = false

	# variable to stop the while loop
	var finished : bool = false


	while !finished:
		# very small delay between every iteration to prevent a crash
		yield(get_tree().create_timer(0.0001), "timeout")

		# first move in every row
		if !movedOnce && posY < HEIGHT - 1:
			# check if the current position is in one of the corners
			if posX > 0 && posX < WIDTH - 1:
				# if not choose a random move; 1 left or 2 right
				nextRoom = random(1,2)
				match nextRoom:
					1:
						posX -= 1
					2:
						posX += 1

			# if you are in one of the corners, there is only one move you can do
			elif posX == 0:
				posX += 1
			elif posX == WIDTH -1:
				posX -= 1

			# setting the next room to a 1 (left-right room)
			map[posY][posX] = "1"

			# after one Move per row you could go down a layer
			movedOnce = true


	# second, third... move
		elif movedOnce && posY < HEIGHT - 1:
			# if you are in one of the corners you must go down
			if posX == 0 || posX == WIDTH - 1:
				# changing the current room into a 2 (left-right-bottom room)
				map[posY][posX] = "2"

				# go down a row
				posY += 1

				# the next room below the current room must be a 3 (left-right-top room)
				map[posY][posX] = "3"
			
				# making sure you have to do at least one move per row
				movedOnce = false


			# else you are in the center and could do a move to the side
			else:
				# to the side (1) or down (2)
				nextRoom = random(1,2)
				
				# move sideways
				if nextRoom == 1:
					# check if the room left to the current position is free
					if map[posY][posX-1] == "0":
						# move to the left side
						posX -= 1
						# setting the next room to a 1 (left-right room)
						map[posY][posX] = "1"

					# else the room to the right must be free
					else:
						# move to the right side
						posX += 1
						# setting the next room to a 1 (left-right room)
						map[posY][posX] = "1"

				# move down
				else:
					# changing the current room into a 2 (left-right-bottom room)
					map[posY][posX] = "2"

					# go down a row
					posY += 1

					# the next room below the current room must be a 3 (left-right-top room)
					map[posY][posX] = "3"

					# making sure you have to do at least one move per row
					movedOnce = false


		# last step (bottom row)
		else:
			# check if the current position is in one of the corners
			if posX > 0 && posX < WIDTH - 1:
				# if not choose a random move; 1 left or 2 right 3 place the exit
				nextRoom = random(1,3)
				match nextRoom:
					1:
						posX -= 1

						# setting the next room to a 1 (left-right room)
						map[posY][posX] = "1"
					2:
						posX += 1

						# setting the next room to a 1 (left-right room)
						map[posY][posX] = "1"
					3:
						map[posY][posX] = "E"

						#end the loop
						finished = true

			# if you are not in one of the corners place the exit
			else:
				map[posY][posX] = "E"

				#end the loop
				finished = true


	# print the map out 
	for d in HEIGHT:
		print(map[d])

	# emit a signal so the next step happens
	emit_signal("mapGenerated")


func placeExtraRooms():
	# in this example I am just replacing fill rooms with random rooms
	# but this would also be the place where you could place, snake pits, shops, traprooms etc.

	# looping tough the 2D Array
	for y in HEIGHT:
		for x in WIDTH:

			# again a small delay to prevent a crash
			yield(get_tree().create_timer(0.0001), "timeout")

			#if the current room is 0 (fill room) it could be replaced
			if map[y][x] == "0":

				# choose a random number between 1 and 10 (change the 10, to change the probabilities; currently 1/10)
				var fillRooms = random(1,10)

				match fillRooms:
					# just place a left right room 
					1:
						map[y][x] = "1"

					# place a left right bottom room
					2:
						# check if you are in the bottom row
						if y < HEIGHT - 1:
							# if not check if the room below the current position is already a left right bottom room
							if map[y+1][x] == "2":
								# if the room below is already a 2, change it to a 4 (left-right-bottom-top room)
								map[y+1][x] = "4"
								# set the current room to a 2
								map[y][x] = "2"
						else:
							# if you are in the bottom row, just place a 2 (left-right-bottom room)
							map[y][x] = "2"

					# place a left right top room
					3:
						# check if you are in the top row
						if y > 0:
							# if not check if the room above he current position is already a left right top room
							if map[y-1][x] == "3":
								# if the room above is already a 3, cahnge it to a 4 (left-right-bottom-top room)
								map[y-1][x] = "4"
								# set the current room to a 3
								map[y][x] = "3"
						else:
							# if not you are in the top row, just place a 3
							map[y][x] = "3"

	# print out the map 
	for d in HEIGHT:
		print(map[d])
	
	# emit a signal so the next step can happen
	emit_signal("extraRoomsPlaced")


func printMap():
	# looping tough the 2D Array
	for y in HEIGHT:
		for x in WIDTH:
			yield(get_tree().create_timer(0.0001), "timeout")

			# variable to the path
			var pathName = ""

			# place a random room based on the character given
			match map[y][x]:
				# start
				"S":
					pathName = str("res://rooms/start/start_", random(1 ,count_files_in_directory("res://rooms/start/")),".tscn")
				
				# left right
				"1":
					pathName = str("res://rooms/left_right/left_right_", random(1 ,count_files_in_directory("res://rooms/left_right/")),".tscn")
				
				# left right bottom
				"2":
					pathName = str("res://rooms/left_right_bottom/left_right_bottom_", random(1 ,count_files_in_directory("res://rooms/left_right_bottom/")),".tscn")
				
				# left right top
				"3":
					pathName = str("res://rooms/left_right_top/left_right_top_", random(1 ,count_files_in_directory("res://rooms/left_right_top/")),".tscn")
				
				# left right bottom top
				"4":
					pathName = str("res://rooms/left_right_bottom_top/left_right_bottom_top_", random(1 ,count_files_in_directory("res://rooms/left_right_bottom_top/")),".tscn")
				
				# exit
				"E":
					pathName = str("res://rooms/exit/exit_", random(1 ,count_files_in_directory("res://rooms/exit/")),".tscn")
				
				# fill
				"0":
					pathName = str("res://rooms/fill/fill_", random(1 ,count_files_in_directory("res://rooms/fill/")),".tscn")
			
			# place the current room at its location
			placeMap(pathName, x * ROOM_WIDTH, y * ROOM_HEIGHT)
			
			emit_signal("mapDrawn")

func placeMap(path, offsetX, offsetY):
	# instance rooms at a given position
	var scene = load(path)
	var instance = scene.instance()
	instance.position = Vector2(offsetX, offsetY)
	$rooms.add_child(instance)

				
func count_files_in_directory(path):
	# method to count the amount of diffrent rooms per type
	# completly optional you could just input the amounts in code
	var files := 0
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files += 1

	dir.list_dir_end()

	return files


func random(minVal, maxVal):
	# return a random value between the given min and max values
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randi_range(minVal, maxVal)
	
