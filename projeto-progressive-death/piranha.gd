extends CharacterBody2D

const SPEED = 100.0
var direction = 1
var distancia = 0.0

@onready var sprite = $Sprite2D

func _physics_process(delta):
	velocity.y = 0
	velocity.x = direction * SPEED
	distancia += SPEED * delta
	if distancia >= 500:
		distancia = 0
		direction = direction * -1
	move_and_slide()
	if is_on_wall():
		direction = direction * -1
	
	if direction < 0:
		sprite.flip_h = false
	if direction > 0:
		sprite.flip_h = true
