extends StaticBody2D

export (int) var width = 1

var playerInside : bool = false
var player : KinematicBody2D = null

func _ready():
	$CollisionShape2D.shape.extents.x = 8 * width
	$CollisionShape2D.position.x += 8 * width - 8 
	$CollisionShape2D.one_way_collision = true

func _process(delta):
	if player != null:
		if playerInside:
			if Input.is_action_pressed("S") && player.get_collision_mask_bit(3):
				player.set_collision_mask_bit(3, false)
		
		else:
			if !player.get_collision_mask_bit(3):
				player.set_collision_mask_bit(3, true)
		
func _on_DropThrough_body_entered(body):
	if body.is_in_group("player"):
		playerInside = true
		player = body

func _on_DropThrough_body_exited(body):
	if body.is_in_group("player"):
		playerInside = false
