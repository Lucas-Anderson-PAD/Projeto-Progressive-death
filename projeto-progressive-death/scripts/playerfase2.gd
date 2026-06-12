extends CharacterBody2D
class_name PlayerFase2

@export var camera: Camera2D

# --- Configurações de Movimento Vertical (A Queda) ---
const BASE_FALL_SPEED = 400.0       # Sem apertar nada: queda padrão mantendo o ritmo da câmera
const DIVE_FALL_SPEED = 900.0       # Apertando para baixo: mergulho rápido
const BRAKE_FALL_SPEED = 200.0      # Apertando para cima: freia a queda
const GLIDE_FALL_SPEED = 50.0      # Botão de planar: freio máximo/paraquedas

# --- Configurações de Movimento Horizontal ---
const HORIZONTAL_SPEED = 600.0      # Velocidade para os lados
const GLIDE_HORIZONTAL_SPEED = 300.0# Movimento lateral reduzido ao planar

const ACCELERATION = 2500.0 # Quão rápido ele atinge a velocidade máxima
const FRICTION = 2000.0     # Quão rápido ele para horizontalmente

# --- Variáveis da Mecânica de Planar/Freio ---
var is_gliding: bool = false
var glide_timer: float = 0.0
const GLIDE_PUNISH_TIME = 3.0 # Segundos segurando o botão antes de atrair o inimigo

# Sinal para instanciar o inimigo caçador
signal spawn_hunter_enemy

# Variável para receber o empurrão do vento
var wind_force: Vector2 = Vector2.ZERO

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
		
		# Medidor de punição por abusar do controle fino
		glide_timer += delta
		if glide_timer >= GLIDE_PUNISH_TIME:
			emit_signal("spawn_hunter_enemy")
			glide_timer = 0.0
	else:
		is_gliding = false
		glide_timer = max(0.0, glide_timer - delta * 2) # Esvazia o medidor

	# 4. Aplicar Movimento Horizontal
	if input_direction.x != 0:
		velocity.x = move_toward(velocity.x, input_direction.x * current_h_speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# 5. Aplicar Movimento Vertical
	# Faz a transição suave entre a queda base, o mergulho e o freio
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

# --- Funções Auxiliares de Limite de Tela CORRIGIDA ---
func _manter_na_camera() -> void:
	var tamanho_tela = get_viewport_rect().size
	var zoom = camera.zoom
	
	# CORREÇÃO: Pegamos o centro visual real da tela do jogo
	var centro_visual_da_camera = camera.get_screen_center_position()
	
	# A matemática agora calcula as bordas baseando-se no que o jogador realmente vê
	var limite_esq = centro_visual_da_camera.x - (tamanho_tela.x / 2) / zoom.x
	var limite_dir = centro_visual_da_camera.x + (tamanho_tela.x / 2) / zoom.x
	var limite_top = centro_visual_da_camera.y - (tamanho_tela.y / 2) / zoom.y
	var limite_bot = centro_visual_da_camera.y + (tamanho_tela.y / 2) / zoom.y
	
	var margem = 30.0 # Evita que ele saia metade do corpo nas bordas
	
	# Aplica a trava em toda a extensão da tela de forma idêntica
	global_position.x = clamp(global_position.x, limite_esq + margem, limite_dir - margem)
	global_position.y = clamp(global_position.y, limite_top + margem, limite_bot - margem)

# --- Funções Auxiliares para o Vento ---
func apply_wind(force: Vector2) -> void:
	wind_force = force

func remove_wind() -> void:
	wind_force = Vector2.ZERO
