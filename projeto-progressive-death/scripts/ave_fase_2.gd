extends Area2D

# --- Configurações de Movimento ---
const VELOCIDADE_BASE = 500.0 # Ritmo da Câmera
const VELOCIDADE_HORIZONTAL_VOO = 250.0

# Valores do Rasante (Parábola)
const FORCA_MERGULHO_Y = 1000.0 
var velocidade_mergulho_x: float = 0.0

# --- Tempo de Duração e Animação ---
const TEMPO_PREPARACAO = 0.6 
var timer_atual: float = 0.0
var tempo_de_engajamento: float = 12.0 

# --- Estados ---
enum Estado { VOANDO, PREPARANDO, MERGULHANDO, SUBINDO }
var estado_atual = Estado.VOANDO

var direcao_x: float = 1.0
var cardeal: CharacterBody2D = null

# NOVO: Referência da câmera, igualzinho no Player!
@export var camera: Camera2D 

@export var anim: AnimatedSprite2D

func _ready() -> void:
	cardeal = get_tree().get_root().find_child("Player", true, false)
	
	# Se esquecer de arrastar a câmera no editor, ele tenta achar sozinho
	if camera == null:
		camera = get_viewport().get_camera_2d()
	
	# Decide a direção baseada no centro real da câmera
	if camera != null:
		var centro_camera = camera.get_screen_center_position().x
		if global_position.x > centro_camera:
			direcao_x = 1.0
			anim.flip_h = true
		else:
			direcao_x = -1.0
			anim.flip_h = false
			
	anim.play("fly")

func _physics_process(delta: float) -> void:
	tempo_de_engajamento -= delta
	
	match estado_atual:
		Estado.VOANDO:
			_estado_voando(delta)
		Estado.PREPARANDO:
			_estado_preparando(delta)
		Estado.MERGULHANDO:
			_estado_mergulhando(delta)
		Estado.SUBINDO:
			_estado_subindo(delta)

# --- LÓGICA DOS ESTADOS ---

func _estado_voando(delta: float) -> void:
	global_position.y += VELOCIDADE_BASE * delta
	global_position.x += VELOCIDADE_HORIZONTAL_VOO * direcao_x * delta
	
	_verificar_bordas_laterais()
	
	if cardeal != null:
		var distancia_y = cardeal.global_position.y - global_position.y
		var distancia_x = abs(cardeal.global_position.x - global_position.x)
		
		if tempo_de_engajamento > 0 and distancia_y > 100 and distancia_y < 450 and distancia_x < 350:
			_iniciar_preparacao()

func _iniciar_preparacao() -> void:
	estado_atual = Estado.PREPARANDO
	timer_atual = TEMPO_PREPARACAO 
	anim.play("prepare")
	
	var direcao_alvo = sign(cardeal.global_position.x - global_position.x)
	velocidade_mergulho_x = max(400.0, abs(cardeal.global_position.x - global_position.x)) * direcao_alvo
	anim.flip_h = (direcao_alvo < 0)

func _estado_preparando(delta: float) -> void:
	global_position.y += VELOCIDADE_BASE * delta
	timer_atual -= delta
	
	if timer_atual <= 0:
		estado_atual = Estado.MERGULHANDO
		anim.play("dive")

func _estado_mergulhando(delta: float) -> void:
	global_position.y += FORCA_MERGULHO_Y * delta
	global_position.x += velocidade_mergulho_x * delta
	
	# Trava da câmera igual à do Cardeal para o mergulho não vazar a tela!
	if camera:
		var tela_x = get_viewport_rect().size.x
		var centro_visual = camera.get_screen_center_position()
		var esq = centro_visual.x - (tela_x / 2) / camera.zoom.x
		var dir = centro_visual.x + (tela_x / 2) / camera.zoom.x
		var margem = 30.0
		global_position.x = clamp(global_position.x, esq + margem, dir - margem)

	if cardeal != null:
		if global_position.y > cardeal.global_position.y + 150:
			if tempo_de_engajamento > 0:
				estado_atual = Estado.SUBINDO
				anim.play("up")

func _estado_subindo(delta: float) -> void:
	global_position.y += 100.0 * delta 
	global_position.x += VELOCIDADE_HORIZONTAL_VOO * direcao_x * delta
	
	_verificar_bordas_laterais()
	
	if cardeal != null:
		if global_position.y < cardeal.global_position.y - 400:
			estado_atual = Estado.VOANDO
			anim.play("fly")

# --- FUNÇÕES DE LIMITES DE TELA (IDÊNTICO AO CARDEAL) ---

func _verificar_bordas_laterais() -> void:
	if camera:
		var tela_x = get_viewport_rect().size.x
		var zoom_x = camera.zoom.x
		var centro_visual = camera.get_screen_center_position()
		
		var esq = centro_visual.x - (tela_x / 2) / zoom_x
		var dir = centro_visual.x + (tela_x / 2) / zoom_x
		
		var margem = 30.0 # Mesma margem do jogador
		
		# Bate e volta nos limites exatos
		if global_position.x < esq + margem:
			direcao_x = 1.0
			anim.flip_h = false
			global_position.x = esq + margem
		elif global_position.x > dir - margem:
			direcao_x = -1.0
			anim.flip_h = true
			global_position.x = dir - margem

# --- LIMPEZA DE MEMÓRIA ---
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if tempo_de_engajamento <= 0:
		queue_free()

# --- SISTEMA DE COMBATE ---
func _on_ponto_fraco_body_entered(body: Node2D) -> void:
	if body is PlayerFase2:
		if Input.is_action_pressed("ui_down"):
			print("Ave derrotada!")
			body.velocity.y = -600.0 
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerFase2:
		if is_queued_for_deletion():
			return
		print("Cardeal tomou dano da ave!")
