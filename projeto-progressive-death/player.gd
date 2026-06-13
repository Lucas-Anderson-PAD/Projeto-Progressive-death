extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const WATER_GRAVITY = 0.1
const WATER_SPEED = 80.0

var water = false

@onready var sprite = $Sprite2D

func _physics_process(delta: float) -> void:
	if not water:
		if not is_on_floor():
			velocity += get_gravity() * delta
	if water:
		swim(delta)

	if Input.is_action_just_pressed("jump") and is_on_floor() and not water:
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		if direction > 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func swim(delta: float) -> void:
	velocity += get_gravity() * WATER_GRAVITY * delta
	var vertical := Input.get_axis("move_up", "move_down")
	if vertical:
		velocity.y = vertical * WATER_SPEED
	
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * WATER_SPEED
		if direction > 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, WATER_SPEED)
		
