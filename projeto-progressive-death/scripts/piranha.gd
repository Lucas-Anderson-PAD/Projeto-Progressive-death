extends CharacterBody2D

# Piranha: SÓ se move dentro da água. Persegue o jogador quando ele está na água
# e dentro do alcance; senão, patrulha de um lado para o outro ATÉ bater numa
# parede/obstáculo, quando então vira e vai para o outro lado.
# Anima a mordida completa ao perseguir. Ao COLIDIR com o jogador por alguns
# segundos, ele morre.

@export var velocidade: float = 100.0           # velocidade ao perseguir
@export var alcance: float = 200.0             # distância para detectar/perseguir
@export var velocidade_patrulha: float = 70.0  # velocidade ao patrulhar
@export var tempo_para_matar: float = 0.2     # segundos de contato até matar
@export var zona_morta: float = 8.0            # tolerância horizontal na espreita (evita tremer)

@onready var sprite: Sprite2D = $Sprite2D

const ANIM_FPS := 8.0

# A água (water.gd) liga/desliga isto quando a piranha entra/sai dela.
var water := false

var _frames: Array = []
var _anim_t: float = 0.0
var _dir_patrulha: int = 1
var _tempo_mordida: float = 0.0


func _ready() -> void:
	# Grupo "inimigo": pode ser morta quando o jogador pula em cima com a bota.
	add_to_group("inimigo")
	_frames = [
		load("res://sprites/Piranha/piranha_0.png"),
		load("res://sprites/Piranha/piranha_1.png"),
		load("res://sprites/Piranha/piranha_2.png"),
		load("res://sprites/Piranha/piranha_3.png"),
		load("res://sprites/Piranha/piranha_4.png"),
	]


# Chamado pelo jogador quando ele pula em cima com a bota equipada.
func morrer() -> void:
	set_physics_process(false)
	queue_free()


func _physics_process(delta: float) -> void:
	# Fora da água a piranha não nada: afunda de volta para a água.
	if not water:
		velocity.x = move_toward(velocity.x, 0.0, velocidade)
		velocity += get_gravity() * delta
		move_and_slide()
		_atualizar_sprite(delta, false)
		return

	var jogador := get_tree().get_first_node_in_group("player") as Node2D

	# Enxerga o jogador se ele estiver no ALCANCE (campo de visão), MESMO que
	# ele esteja FORA da água. A piranha só não consegue SAIR da água.
	var no_alcance := jogador != null and global_position.distance_to(jogador.global_position) <= alcance
	var jogador_na_agua := jogador != null and bool(jogador.get("water"))

	if no_alcance and jogador_na_agua:
		# Jogador na água: persegue de verdade (horizontal e vertical).
		velocity = (jogador.global_position - global_position).normalized() * velocidade
	elif no_alcance:
		# Jogador fora da água: fica à espreita, só acompanhando na HORIZONTAL
		# (velocity.y = 0), sem tentar subir e sair da água. A zona morta evita
		# tremer/virar o sprite quando o jogador está quase em cima.
		var dx := jogador.global_position.x - global_position.x
		var dir_x := 0.0 if absf(dx) < zona_morta else signf(dx)
		velocity = Vector2(dir_x * velocidade, 0.0)
	else:
		# PATRULHA: nada para um lado; vira só ao bater em algo (logo abaixo).
		velocity = Vector2(_dir_patrulha * velocidade_patrulha, 0.0)

	move_and_slide()

	# Patrulhando e bateu numa parede/obstáculo -> vira para o outro lado.
	if not no_alcance and is_on_wall():
		_dir_patrulha *= -1

	# Mordida pela COLISÃO real, mas SÓ com o jogador dentro da água (a piranha
	# não morde quem está fora dela): conta o tempo de contato; ao atingir
	# tempo_para_matar, ele morre.
	if jogador_na_agua and _colidindo_com_jogador():
		_tempo_mordida += delta
		if _tempo_mordida >= tempo_para_matar:
			Inventario.perder_vida()
			_tempo_mordida = 0.0
	else:
		_tempo_mordida = 0.0

	_atualizar_sprite(delta, no_alcance)


# Verifica se alguma colisão deste frame (move_and_slide) foi com o jogador.
func _colidindo_com_jogador() -> bool:
	for i in get_slide_collision_count():
		var c := get_slide_collision(i).get_collider() as Node
		if c != null and c.is_in_group("player"):
			return true
	return false


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
