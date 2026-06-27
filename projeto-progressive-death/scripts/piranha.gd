extends CharacterBody2D

# Piranha com IA simples: persegue o jogador quando ele entra no alcance e
# patrulha (vai e volta) quando ele está longe. Anima a mordida (5 frames).

@export var velocidade: float = 150.0          # velocidade ao perseguir
@export var alcance: float = 500.0             # distância para detectar/perseguir
@export var velocidade_patrulha: float = 70.0
@export var distancia_patrulha: float = 400.0  # quanto anda antes de virar

@onready var sprite: Sprite2D = $Sprite2D

const ANIM_FPS := 8.0

var _frames: Array = []
var _anim_t: float = 0.0
var _dir_patrulha: int = 1
var _percorrido: float = 0.0


func _ready() -> void:
	# Frames da animação (mordida). Todos apontam para a esquerda.
	_frames = [
		load("res://sprites/Piranha/piranha_0.png"),
		load("res://sprites/Piranha/piranha_1.png"),
		load("res://sprites/Piranha/piranha_2.jpg"),
		load("res://sprites/Piranha/piranha_3.jpg"),
		load("res://sprites/Piranha/piranha_4.png"),
	]


func _physics_process(delta: float) -> void:
	var jogador = get_tree().get_first_node_in_group("player")

	if jogador != null and global_position.distance_to(jogador.global_position) <= alcance:
		# PERSEGUE: nada na direção do jogador (em 2D).
		var dir := (jogador.global_position - global_position).normalized()
		velocity = dir * velocidade
	else:
		# PATRULHA: vai e volta na horizontal.
		velocity = Vector2(_dir_patrulha * velocidade_patrulha, 0.0)
		_percorrido += velocidade_patrulha * delta
		if _percorrido >= distancia_patrulha:
			_percorrido = 0.0
			_dir_patrulha *= -1

	move_and_slide()

	# Bateu na parede patrulhando: inverte.
	if is_on_wall():
		_dir_patrulha *= -1

	_atualizar_sprite(delta)


func _atualizar_sprite(delta: float) -> void:
	# Os frames apontam para a ESQUERDA; espelha quando vai para a direita.
	if velocity.x > 1.0:
		sprite.flip_h = true
	elif velocity.x < -1.0:
		sprite.flip_h = false

	# Anima a mordida em loop.
	if _frames.is_empty():
		return
	_anim_t += delta * ANIM_FPS
	sprite.texture = _frames[int(_anim_t) % _frames.size()]
