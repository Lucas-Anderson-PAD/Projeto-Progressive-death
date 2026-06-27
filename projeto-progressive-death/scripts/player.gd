extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
# Pulinho dentro da água (impulso pra cima, para conseguir sair da água).
const PULO_AGUA = -350.0
const WATER_GRAVITY = 0.1
const WATER_SPEED = 80.0
# Resistência da água: quanto maior, mais rápido a água freia a queda/movimento.
const WATER_DRAG = 6.0
# Tempo (em segundos) que o jogador aguenta na água SEM capacete antes de morrer.
const TEMPO_AFOGAMENTO = 1.0
# Velocidade da animação (frames por segundo).
const ANIM_FPS := 6.0

# Vá no Inspetor e coloque a altura aproximada do seu pássaro em pixels.
@export var altura_jogador: float = 32.0

# Se o jogador está com o capacete. COM capacete ele respira na água e nada;
# SEM, ele se afoga. Começa false e vira true ao pegar o item capacete.
@export var tem_capacete: bool = false

# Folhas de animação (cada uma é um grid 2x2 = 4 frames).
# Frames por direção: esquerda = [0, 2], direita = [1, 3].
@export var textura_andar: Texture2D
@export var textura_andar_capacete: Texture2D
@export var textura_nadar: Texture2D
# Folhas dedicadas do PULO (também grid 2x2; frames apontam para a direita).
@export var textura_pulo: Texture2D
@export var textura_pulo_capacete: Texture2D

@onready var sprite = $Sprite2D

var water = false

# Controle do dano de queda
var ponto_mais_alto: float = 0.0
var estava_no_ar: bool = false
var limite_queda_fatal: float = 0.0

# Cronômetro de afogamento (conta o tempo dentro d'água sem capacete).
var tempo_na_agua: float = 0.0

# Animação
var _facing := 1      # 1 = direita, -1 = esquerda
var _anim_t := 0.0


func _ready():
	# Entra no grupo "player" para que portais e itens encontrem o jogador.
	add_to_group("player")

	# Calcula o limite baseado no valor do Inspetor
	limite_queda_fatal = altura_jogador * 20


func _physics_process(delta: float) -> void:
	if water:
		# Dentro d'água não há queda fatal: reseta o rastreamento.
		swim(delta)
		estava_no_ar = false

		# Afogamento: sem capacete, morre TEMPO_AFOGAMENTO segundos após entrar.
		if not tem_capacete:
			tempo_na_agua += delta
			if tempo_na_agua >= TEMPO_AFOGAMENTO:
				print("!!! AFOGOU (sem capacete) - MORREU !!!")
				Inventario.limpar()
				get_tree().reload_current_scene()
				return
	else:
		# Fora d'água: zera o cronômetro de afogamento.
		tempo_na_agua = 0.0

		# 1. JOGADOR NO AR
		if not is_on_floor():
			velocity += get_gravity() * delta

			if not estava_no_ar:
				estava_no_ar = true
				ponto_mais_alto = global_position.y

			if global_position.y < ponto_mais_alto:
				ponto_mais_alto = global_position.y

	# 2. PULO
	if Input.is_action_just_pressed("jump"):
		if water:
			# Dentro d'água: pulinho pra cima para conseguir sair da água.
			velocity.y = PULO_AGUA
		elif is_on_floor():
			# Em terra firme: pulo normal.
			velocity.y = JUMP_VELOCITY

	# 3. MOVIMENTO LATERAL EM TERRA (na água quem cuida disso é o swim())
	if not water:
		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * SPEED
			_facing = 1 if direction > 0 else -1
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. APLICA A FÍSICA
	move_and_slide()

	# 5. ANIMAÇÃO (sprite conforme o estado e a direção)
	var movendo := absf(velocity.x) > 5.0 or (water and absf(velocity.y) > 5.0)
	_atualizar_animacao(delta, movendo)

	# 6. IMPACTO (só faz sentido fora d'água)
	if not water and is_on_floor() and estava_no_ar:
		var distancia_da_queda = global_position.y - ponto_mais_alto
		if distancia_da_queda >= limite_queda_fatal:
			print("!!! PASSOU DO LIMITE - MORREU !!!")
			Inventario.limpar()
			get_tree().reload_current_scene()
		estava_no_ar = false


func swim(delta: float) -> void:
	# Empuxo: dentro d'água a gravidade quase não age.
	velocity += get_gravity() * WATER_GRAVITY * delta

	# Resistência da água: freia QUALQUER velocidade (inclui a queda ao entrar).
	velocity = velocity.lerp(Vector2.ZERO, min(WATER_DRAG * delta, 1.0))

	# Natação vertical controlada pelo jogador (sobe/desce).
	var vertical := Input.get_axis("move_up", "move_down")
	if vertical:
		velocity.y = vertical * WATER_SPEED

	# Natação horizontal controlada pelo jogador.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * WATER_SPEED
		_facing = 1 if direction > 0 else -1


# Troca a folha e anima os frames conforme o estado e a direção.
# Nas folhas de andar/pulo o pássaro aponta para a DIREITA (frames 1,2,3) e nas
# de nadar para a ESQUERDA; o flip_h corrige a direção quando preciso.
func _atualizar_animacao(delta: float, movendo: bool) -> void:
	if sprite == null:
		return

	var tex: Texture2D
	var frames: Array
	var native_dir: int      # direção para a qual os frames já apontam
	var anima := false

	if water and tem_capacete:
		# NADANDO (só com capacete): anima sempre, só por estar na água.
		tex = textura_nadar
		frames = [0, 1, 2, 3]
		native_dir = -1
		anima = true
	elif water:
		# Na água SEM capacete: está se afogando (morre em 1s). NÃO usa o sprite
		# de nado com capacete; mostra o pássaro normal, sem capacete.
		tex = textura_andar
		frames = [1]
		native_dir = 1
		anima = false
	else:
		native_dir = 1
		if not is_on_floor():
			# PULO / no ar: folha dedicada de pulo, frames [2,1,3] (sem o frame 0).
			tex = textura_pulo_capacete if (tem_capacete and textura_pulo_capacete != null) else textura_pulo
			if tex == null:
				tex = textura_andar_capacete if (tem_capacete and textura_andar_capacete != null) else textura_andar
			frames = [2, 1, 3]
			anima = true
		else:
			# EM TERRA: folha de andar (com ou sem capacete).
			tex = textura_andar_capacete if (tem_capacete and textura_andar_capacete != null) else textura_andar
			if movendo:
				# ANDAR.
				frames = [1, 3]
				anima = true
			else:
				# PARADO.
				frames = [1]

	if tex != null and sprite.texture != tex:
		sprite.texture = tex

	# Direção: vira o sprite quando o jogador olha para o lado oposto ao nativo.
	sprite.flip_h = (_facing != native_dir)

	# Frame atual.
	if anima and frames.size() > 1:
		_anim_t += delta * ANIM_FPS
		sprite.frame = frames[int(_anim_t) % frames.size()]
	else:
		_anim_t = 0.0
		sprite.frame = frames[0]
