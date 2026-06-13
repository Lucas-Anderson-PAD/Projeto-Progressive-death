extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Coloquei a altura como Export. 
# Vá no Inspetor do Godot e coloque a altura aproximada do seu pássaro em pixels (ex: 32 ou 64).
@export var altura_jogador: float = 32.0 

@onready var sprite = $Sprite2D # Se o seu for AnimatedSprite2D, isso vai funcionar igual

var ponto_mais_alto: float = 0.0
var estava_no_ar: bool = false
var limite_queda_fatal: float = 0.0

func _ready():
	# Calcula o limite baseado no valor do Inspetor
	limite_queda_fatal = altura_jogador * 12
	
	print("--- JOGO INICIADO ---")
	print("Altura do pássaro: ", altura_jogador, " pixels")
	print("Morte se cair mais de: ", limite_queda_fatal, " pixels")

func _physics_process(delta: float) -> void:
	# 1. JOGADOR NO AR
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		# Registra o exato momento que tirou o pé do chão
		if not estava_no_ar:
			estava_no_ar = true
			ponto_mais_alto = global_position.y
			print("-> Saiu do chão! Gravando altura inicial...")
		
		# Atualiza o ponto mais alto (no Godot, subir = Y menor)
		if global_position.y < ponto_mais_alto:
			ponto_mais_alto = global_position.y

	# 2. PULO
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. MOVIMENTO LATERAL
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		sprite.flip_h = (direction > 0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. APLICA A FÍSICA
	move_and_slide()

	# 5. IMPACTO (logo após o move_and_slide calcular se bateu no chão)
	if is_on_floor() and estava_no_ar:
		var distancia_da_queda = global_position.y - ponto_mais_alto
		var proporcao = distancia_da_queda / altura_jogador
		
		# Printa o relatório do impacto
		print("=> Bateu no chão! Altura da queda: %.2fx (Total: %d pixels)" % [proporcao, int(distancia_da_queda)])
		
		if distancia_da_queda >= limite_queda_fatal:
			print("!!! PASSOU DO LIMITE - MORREU !!!")
			get_tree().reload_current_scene()
			
		# Sobreviveu, reseta para o próximo pulo
		estava_no_ar = false
