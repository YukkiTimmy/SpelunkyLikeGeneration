extends KinematicBody2D

enum STATES {IDLE, FOLLOWIGNG}
var state = STATES.IDLE

var player : KinematicBody2D = null

const DAMAGE : int = 1
const SPEED : int = 35

var velocity : Vector2 = Vector2.ZERO

func _physics_process(delta):
	match state:
		STATES.FOLLOWIGNG:
			movement_loop(delta)
			
		STATES.IDLE:
			pass


func movement_loop(delta):
	var dir = (player.global_position - global_position).normalized()
	move_and_collide(dir * SPEED * delta)



func _on_DetectionRadius_body_entered(body):
	if body.is_in_group("player") && state == STATES.IDLE:
		state = STATES.FOLLOWIGNG
		player = body
