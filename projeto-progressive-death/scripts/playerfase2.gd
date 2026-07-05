extends CharacterBody2D
class_name PlayerFase2

@export var camera: Camera2D

# Escolha da animação pelo Inspetor (aplica ao rodar o jogo):
#   PULO_FASE1 -> Sprite2D com a folha de PULO da fase 1 (asas abertas).
#   DIVE_BOMB  -> AnimatedSprite2D novo (atlas Cardeal-dive_bomb).
enum EstiloAnimacao { PULO_FASE1, DIVE_BOMB }
@export var estilo_animacao: EstiloAnimacao = EstiloAnimacao.PULO_FASE1

# --- Animação estilo FASE 1 (Sprite2D + folha de pulo, grid 2x2) ---
@onready var sprite: Sprite2D = $Sprite2D
const TEXTURA_PULO := preload("res://sprites/caedeal/pulando/cardeal pulando.png")
const ANIM_FPS := 6.0
const FRAMES_PULO := [2, 1, 3]

# --- Animação estilo FASE 2 (AnimatedSprite2D do parceiro) ---
@onready var anim: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

# --- Configurações de Movimento Vertical (A Queda) ---
const BASE_FALL_SPEED = 400.0       # Sem apertar nada: queda padrão mantendo o ritmo da câmera
const DIVE_FALL_SPEED = 900.0       # Apertando para baixo: mergulho rápido
const BRAKE_FALL_SPEED = 200.0      # Apertando para cima: freia a queda
const GLIDE_FALL_SPEED = 50.0       # Botão de planar: freio máximo/paraquedas

# --- Configurações de Movimento Horizontal ---
const HORIZONTAL_SPEED = 600.0      # Velocidade para os lados
const GLIDE_HORIZONTAL_SPEED = 300.0# Movimento lateral reduzido ao planar

const ACCELERATION = 2500.0 # Quão rápido ele atinge a velocidade máxima
const FRICTION = 2000.0     # Quão rápido ele para horizontalmente

# --- Variáveis da Mecânica de Planar/Freio ---
var is_gliding: bool = false
var glide_timer: float = 0.0
const GLIDE_PUNISH_TIME = 3.0 # Segundos segurando o botão antes de atrair o inimigo

# Variável para receber o empurrão do vento
var wind_force: Vector2 = Vector2.ZERO

# Direção horizontal atual (1 = direita, -1 = esquerda) para virar o sprite.
var _facing: int = 1
var _anim_t: float = 0.0

# Bota equipada (o autoload Inventario preenche isto a cada frame, como na fase 1).
# Na fase 2 serve para poder derrotar as aves mergulhando no ponto fraco.
var tem_bota := false

func _ready() -> void:
	# Entra no grupo "player" para que os portais consigam encontrar o jogador.
	add_to_group("player")
	# Já começa com o estado certo da bota (evita a janela de 1 frame antes do
	# Inventario._process; depois ele mantém atualizado se o jogador trocar de item).
	tem_bota = Inventario.bota_equipada()
	_configurar_animacao()

# Mostra só o nó da animação escolhida no Inspetor e esconde o outro.
func _configurar_animacao() -> void:
	var usa_fase1 := estilo_animacao == EstiloAnimacao.PULO_FASE1
	if sprite:
		sprite.visible = usa_fase1
		if usa_fase1:
			sprite.texture = TEXTURA_PULO
			sprite.hframes = 2
			sprite.vframes = 2
	if anim:
		anim.visible = not usa_fase1

func _physics_process(delta: float) -> void:
	# 1. Capturar o Input nas 4 direções (Vector2)
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# 2. Definir Velocidades Alvo Iniciais
	var target_v_speed = BASE_FALL_SPEED # Sempre quer cair por padrão
	var current_h_speed = HORIZONTAL_SPEED

	# Verifica o eixo Y para alterar a velocidade de queda (se não estiver planando)
	if input_direction.y > 0:
		target_v_speed = DIVE_FALL_SPEED # Mergulho
	elif input_direction.y < 0:
		target_v_speed = BRAKE_FALL_SPEED # Freio leve

	# 3. Lógica de Planar (Sobrescreve as configurações acima)
	if Input.is_action_pressed("planar"):
		is_gliding = true
		current_h_speed = GLIDE_HORIZONTAL_SPEED
		target_v_speed = GLIDE_FALL_SPEED
	else:
		# CORREÇÃO: Garante que ele para de planar ao soltar o botão!
		is_gliding = false

	# 4. Aplicar Movimento Horizontal
	if input_direction.x != 0:
		velocity.x = move_toward(velocity.x, input_direction.x * current_h_speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# 5. Aplicar Movimento Vertical
	velocity.y = move_toward(velocity.y, target_v_speed, ACCELERATION * delta)

	# 6. Adiciona a força do vento e Move
	var final_velocity = velocity + wind_force

	var original_velocity = velocity
	velocity = final_velocity

	move_and_slide()

	velocity = original_velocity

	# 7. Prende o jogador na tela
	if camera:
		_manter_na_camera()

	# 8. Atualiza as animações
	_atualizar_animacoes(input_direction, delta)


# --- SISTEMA DE ANIMAÇÕES (escolhe o estilo pelo Inspetor) ---
func _atualizar_animacoes(input_dir: Vector2, delta: float) -> void:
	if estilo_animacao == EstiloAnimacao.PULO_FASE1:
		_anim_fase1(input_dir, delta)
	else:
		_anim_fase2(input_dir)

# FASE 1: folha de PULO (asas abertas) — caindo ou subindo fica no ar.
func _anim_fase1(input_dir: Vector2, delta: float) -> void:
	if sprite == null:
		return
	if sprite.texture != TEXTURA_PULO:
		sprite.texture = TEXTURA_PULO
	# Vira o sprite (os frames apontam para a DIREITA).
	if input_dir.x > 0:
		_facing = 1
	elif input_dir.x < 0:
		_facing = -1
	sprite.flip_h = (_facing != 1)
	# Anima os frames de pulo (asas abertas).
	_anim_t += delta * ANIM_FPS
	sprite.frame = FRAMES_PULO[int(_anim_t) % FRAMES_PULO.size()]

# FASE 2: AnimatedSprite2D do parceiro (cima/direita/idle/planar/queda).
func _anim_fase2(input_dir: Vector2) -> void:
	if anim == null:
		return
	# Virar o sprite para a esquerda ou direita
	if input_dir.x > 0:
		anim.flip_h = false # Olha para a direita
	elif input_dir.x < 0:
		anim.flip_h = true  # Olha para a esquerda
	# Máquina de Prioridades de Animação
	if is_gliding:
		anim.play("planar")
	elif input_dir.x != 0:
		anim.play("direita")
	elif input_dir.y > 0:
		anim.play("queda")
	elif input_dir.y < 0:
		anim.play("cima")
	else:
		anim.play("idle")


# --- Funções Auxiliares de Limite de Tela ---
func _manter_na_camera() -> void:
	var tamanho_tela = get_viewport_rect().size
	var zoom = camera.zoom

	var centro_visual_da_camera = camera.get_screen_center_position()

	var limite_esq = centro_visual_da_camera.x - (tamanho_tela.x / 2) / zoom.x
	var limite_dir = centro_visual_da_camera.x + (tamanho_tela.x / 2) / zoom.x
	var limite_top = centro_visual_da_camera.y - (tamanho_tela.y / 2) / zoom.y
	var limite_bot = centro_visual_da_camera.y + (tamanho_tela.y / 2) / zoom.y

	var margem = 30.0

	global_position.x = clamp(global_position.x, limite_esq + margem, limite_dir - margem)
	global_position.y = clamp(global_position.y, limite_top + margem, limite_bot - margem)

# --- Funções Auxiliares para o Vento ---
func apply_wind(force: Vector2) -> void:
	wind_force = force

func remove_wind() -> void:
	wind_force = Vector2.ZERO
