extends KinematicBody2D

const SPEED = 25
const GRAVITY = 10
const FLOOR = Vector2.DOWN

var velocity : Vector2 = Vector2.ZERO
var dir : Vector2 = Vector2.LEFT

onready var left := $Left
onready var right := $Right

func _physics_process(delta):
	velocity.x = dir.x * SPEED
	velocity.y += SPEED
	
	move_and_slide(velocity, FLOOR)
	
	if is_on_wall() or not left.is_colliding() or not right.is_colliding():
		dir.x *= -1
