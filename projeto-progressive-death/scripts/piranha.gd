extends CharacterBody2D

# Piranha: SÓ se move dentro da água. Persegue o jogador quando ele está na água
# e dentro do alcance; senão, patrulha de um lado para o outro ATÉ bater numa
# parede/obstáculo, quando então vira e vai para o outro lado.
# Anima a mordida completa ao perseguir. Ao encostar por alguns segundos, mata.

@export var velocidade: float = 90.0           # velocidade ao perseguir
@export var alcance: float = 500.0             # distância para detectar/perseguir
@export var velocidade_patrulha: float = 70.0  # velocidade ao patrulhar
@export var raio_mordida: float = 50.0         # distância para "morder"
@export var tempo_para_matar: float = 1.0      # segundos de contato até matar

@onready var sprite: Sprite2D = $Sprite2D

const ANIM_FPS := 8.0

# A água (water.gd) liga/desliga isto quando a piranha entra/sai dela.
var water := false

var _frames: Array = []
var _anim_t: float = 0.0
var _dir_patrulha: int = 1
var _tempo_mordida: float = 0.0


func _ready() -> void:
	_frames = [
		load("res://sprites/Piranha/piranha_0.png"),
		load("res://sprites/Piranha/piranha_1.png"),
		load("res://sprites/Piranha/piranha_2.png"),
		load("res://sprites/Piranha/piranha_3.png"),
		load("res://sprites/Piranha/piranha_4.png"),
	]


func _physics_process(delta: float) -> void:
	# Fora da água a piranha não nada: afunda de volta para a água.
	if not water:
		velocity.x = move_toward(velocity.x, 0.0, velocidade)
		velocity += get_gravity() * delta
		move_and_slide()
		_atualizar_sprite(delta, false)
		return

	var jogador := get_tree().get_first_node_in_group("player") as Node2D

	# Só persegue se o jogador TAMBÉM está na água e dentro do alcance.
	var perseguindo := jogador != null and bool(jogador.get("water")) and global_position.distance_to(jogador.global_position) <= alcance

	if perseguindo:
		# PERSEGUE: nada na direção do jogador.
		velocity = (jogador.global_position - global_position).normalized() * velocidade
	else:
		# PATRULHA: nada para um lado; vira só ao bater em algo (logo abaixo).
		velocity = Vector2(_dir_patrulha * velocidade_patrulha, 0.0)

	move_and_slide()

	# Patrulhando e bateu numa parede/obstáculo -> vira para o outro lado.
	if not perseguindo and is_on_wall():
		_dir_patrulha *= -1

	# Mordida: depois de tempo_para_matar segundos de contato, o jogador morre.
	if jogador != null and global_position.distance_to(jogador.global_position) <= raio_mordida:
		_tempo_mordida += delta
		if _tempo_mordida >= tempo_para_matar:
			Inventario.limpar()
			get_tree().reload_current_scene()
			return
	else:
		_tempo_mordida = 0.0

	_atualizar_sprite(delta, perseguindo)


func _atualizar_sprite(delta: float, perseguindo: bool) -> void:
	# Os frames apontam para a ESQUERDA; espelha quando vai para a direita.
	if velocity.x > 1.0:
		sprite.flip_h = true
	elif velocity.x < -1.0:
		sprite.flip_h = false

	if _frames.is_empty():
		return

	# Perseguindo: mordida completa (5 frames). Patrulhando: só frames 0 e 1.
	var seq := [0, 1, 2, 3, 4] if perseguindo else [0, 1]
	_anim_t += delta * ANIM_FPS
	sprite.texture = _frames[seq[int(_anim_t) % seq.size()]]
