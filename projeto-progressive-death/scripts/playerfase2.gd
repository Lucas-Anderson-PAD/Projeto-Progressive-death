extends CharacterBody2D
class_name PlayerFase2

@export var camera: Camera2D
# --- Configurações de Movimento ---
const BASE_SPEED = 1000.0 # Velocidade normal de movimentação nas 4 direções
const GLIDE_SPEED = 150.0 # Velocidade reduzida ao "planar" (freio de precisão)
const ACCELERATION = 2000.0 # Quão rápido ele atinge a velocidade máxima
const FRICTION = 1500.0 # Quão rápido ele para quando solta os botões

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
	# Certifique-se de ter configurado as ações ui_up, ui_down, ui_left e ui_right no mapa de entrada.
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. Lógica de Planar (Modo de Precisão)
	var current_speed = BASE_SPEED
	
	if Input.is_action_pressed("planar"):
		is_gliding = true
		current_speed = GLIDE_SPEED # Reduz a velocidade para desvios precisos
		
		# Medidor de punição por abusar do controle fino
		glide_timer += delta
		if glide_timer >= GLIDE_PUNISH_TIME:
			emit_signal("spawn_hunter_enemy")
			glide_timer = 0.0
	else:
		is_gliding = false
		glide_timer = max(0.0, glide_timer - delta * 2) # Esvazia o medidor

	# 3. Aplicar Movimento e Vento
	if input_direction != Vector2.ZERO:
		# Acelera na direção do input
		velocity = velocity.move_toward(input_direction * current_speed, ACCELERATION * delta)
	else:
		# Desacelera quando não há input (fricção)
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	# Adiciona a força do vento de forma contínua
	# Importante: O vento não entra na variável 'velocity' permanente, 
	# ele é somado apenas na hora de mover, para não acumular e tirar o controle do jogador.
	var final_velocity = velocity + wind_force
	
	# Passa a final_velocity temporariamente para a variável nativa antes de mover
	var original_velocity = velocity
	velocity = final_velocity
	
	move_and_slide()
	
	# Restaura a velocidade do jogador (sem o vento) para o próximo frame
	velocity = original_velocity

# --- Funções Auxiliares para o Vento ---

# Chamado por um Area2D (ex: vento horizontal empurrando para a direita: Vector2(300, 0))
func apply_wind(force: Vector2) -> void:
	wind_force = force

# Chamado quando sai do Area2D
func remove_wind() -> void:
	wind_force = Vector2.ZERO
