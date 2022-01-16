extends KinematicBody2D

export (int) var ACCELERATION = 20
export (int) var MAX_SPEED = 95
export (int) var VERTICAL_CLIMBING_SPEED = 50
export (int) var HORIZONTAL_CLIMBING_SPEED = 20 
export (int) var GRAVITY = 10
export (int) var JUMP_POWER = -180

const FLOOR = Vector2(0,-1)

var max_hp : int = 3
var current_hp : int = max_hp

var hitstun : float = 0

var max_ropes : int = 5
var current_ropes : int = max_ropes

var max_bombs : int = 5
var current_bombs : int = max_bombs

var velocity : Vector2 = Vector2.ZERO
var velocity_prev : Vector2 = Vector2.ZERO
var hit_the_ground : bool = false

var spritedir : Vector2 = Vector2.ZERO
var movedir : Vector2 = Vector2.ZERO

enum STATES {DEFAULT, LADDER, LEDGE}
var state = STATES.DEFAULT

onready var anim = $anim

onready var upperRightLedgeRay = $UpperRightRay
onready var lowerRightLedgeRay = $LowerRightRay

onready var upperLeftLedgeRay = $UpperLeftRay
onready var lowerLeftLedgeRay = $LowerLeftRay

onready var floorRay = $FloorRay

func _physics_process(delta):
	match state:
		STATES.DEFAULT:
			movement_loop()
			animation_loop()
			check_for_ledge()
			damage_loop()
			place_rope()
			place_bomb()
						
		STATES.LADDER:
			ladder_movement_loop()
			animation_loop()
			place_rope()
			place_bomb()
			
		STATES.LEDGE:
			ledge_movement_loop()
			animation_loop()
			place_rope()
			place_bomb()
			
			
func movement_loop():
	var friction : bool = false
	
	#Walking left and right
	if Input.is_action_pressed("D"):
		velocity.x = min(velocity.x + ACCELERATION, MAX_SPEED)
		spritedir = Vector2.RIGHT
		
	elif Input.is_action_pressed("A"):
		velocity.x = max(velocity.x - ACCELERATION, -MAX_SPEED)
		spritedir = Vector2.LEFT
	
	else:
		friction = true
	
	
	#Jumping
	if Input.is_action_just_pressed("Space") && is_on_floor():
		velocity.y = JUMP_POWER
	
	elif Input.is_action_just_released("Space") && velocity.y <= JUMP_POWER/2:
		# warning-ignore:integer_division
		velocity.y = JUMP_POWER / 2
	
	#Sliding 
	if is_on_floor() && friction:
		velocity.x = lerp(velocity.x, 0, 0.15)
	else:
		velocity.x = lerp(velocity.x, 0, 0.05)
	
	#Check for a Ladder
	for n in $Checker.get_overlapping_areas():
		if n.is_in_group("climbable") && Input.is_action_just_pressed("W"):
			state = STATES.LADDER
			velocity = Vector2.ZERO
		
		if n.is_in_group("dropThrough") && Input.is_action_just_pressed("S"):
			state = STATES.LADDER
			velocity = Vector2.ZERO

	
	#Gravity
	velocity.y += GRAVITY
	
	velocity_prev = velocity
	velocity = move_and_slide_with_snap(velocity, Vector2(0,1),FLOOR)

func damage_loop():
	if hitstun == 0:
		for area in $HurtBox.get_overlapping_areas():
			if area.name == "HitBox":
				var body = area.get_parent()
				if body.is_in_group("enemies"):
					hitstun = 100
					current_hp -= body.DAMAGE
	
	if hitstun > 0:
		hitstun -= 1
		$Sprite.set_modulate(Color("7dffffff"))
	else:
		$Sprite.set_modulate(Color("ffffffff"))
	
	$Label.text = str(current_hp, "/", max_hp)

func ladder_movement_loop():
	
	#climbing up and down
	movedir.y = -int(Input.is_action_pressed("W")) + int(Input.is_action_pressed("S"))
	movedir.x = -int(Input.is_action_pressed("A")) + int(Input.is_action_pressed("D"))
	
	#cancel climbing
	if Input.is_action_just_pressed("Space"):
		velocity.y = JUMP_POWER
		state = STATES.DEFAULT
		
	elif Input.is_action_just_released("Space") && velocity.y <= JUMP_POWER/2:
		# warning-ignore:integer_division
		velocity.y = JUMP_POWER / 2
		state = STATES.DEFAULT
	
	var stillOnLadder = false
	for n in $Checker.get_overlapping_areas():
		if stillOnLadder == false && n.is_in_group("climbable"):
			stillOnLadder = true
			
	if stillOnLadder == false:
		state = STATES.DEFAULT
	
	var motion : Vector2 = movedir.normalized()
	motion.x *= HORIZONTAL_CLIMBING_SPEED
	motion.y *= VERTICAL_CLIMBING_SPEED
	
	move_and_slide(motion, Vector2.ZERO)


func check_for_ledge():
	if !upperRightLedgeRay.is_colliding() && lowerRightLedgeRay.is_colliding() && Input.is_action_pressed("D"):
		if lowerRightLedgeRay.get_collider().name != "Player" && !floorRay.is_colliding() && velocity.y > 0:
			state = STATES.LEDGE
			velocity = Vector2.ZERO
			
	elif !upperLeftLedgeRay.is_colliding() && lowerLeftLedgeRay.is_colliding() && Input.is_action_pressed("A"):
		if lowerLeftLedgeRay.get_collider().name != "Player" && !floorRay.is_colliding() && velocity.y > 0:
			state = STATES.LEDGE
			velocity = Vector2.ZERO
			

func ledge_movement_loop():
	#Jumping
	if Input.is_action_just_pressed("Space"):
		velocity.y = JUMP_POWER
		state = STATES.DEFAULT
	
	elif Input.is_action_just_released("Space") && velocity.y <= JUMP_POWER/2:
		# warning-ignore:integer_division
		velocity.y = JUMP_POWER / 2
		state = STATES.DEFAULT
	
	elif Input.is_action_just_pressed("S"):
		# warning-ignore:integer_division
		velocity.y = JUMP_POWER / 2
		state = STATES.DEFAULT
	
	velocity_prev = velocity
	velocity = move_and_slide_with_snap(velocity, Vector2(0,1),FLOOR)


func place_rope():
	if Input.is_action_just_pressed("K") and current_ropes:
		var scene = load("res://scenes/projectiles/ropeProjectile.tscn")
		var instance = scene.instance()
		if Input.is_action_pressed("W"):
			instance.position = position + spritedir
		else:
			instance.position = position + spritedir * 16
			
		get_parent().add_child(instance)
		
		current_ropes -= 1


func place_bomb():
	if Input.is_action_just_pressed("J") and current_bombs > 0:
		var scene = load("res://scenes/projectiles/bomb.tscn")
		var instance = scene.instance()
		instance.position = position
		get_parent().add_child(instance)
		
		current_bombs -= 1
				

func animation_loop():
	match state:
		STATES.DEFAULT:
			if spritedir == Vector2.RIGHT && is_on_floor() && round(velocity.x) > 0:
				anim.play("walking_right")
			
			elif spritedir == Vector2.LEFT && is_on_floor() && round(velocity.x) < 0:
				anim.play("walking_left")
			
			elif spritedir == Vector2.RIGHT && !is_on_floor():
				anim.play("jumping_right")
			
			elif spritedir == Vector2.LEFT && !is_on_floor():
				anim.play("jumping_left")
			
			elif spritedir == Vector2.RIGHT:
				anim.play("idle_right")
			
			elif spritedir == Vector2.LEFT: 
				anim.play("idle_left")
		
		STATES.LEDGE:
			if spritedir == Vector2.LEFT:
				anim.play("hanging_left")
			else:
				anim.play("hanging_right")
				
		STATES.LADDER:
			if movedir == Vector2.ZERO:
				anim.play("climbing_idle")
			else:
				anim.play("climbing")
		
	
