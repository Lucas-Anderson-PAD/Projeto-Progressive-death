extends StaticBody2D

# O @export faz essas variáveis aparecerem no painel Inspetor!
@export var tempo_ligada: float = 2.0
@export var tempo_desligada: float = 2.0
@export var atraso_inicial: float = 0.0 # É aqui que criamos a sequência!

@onready var timer = $Timer
@onready var sprite = $Sprite2D
@onready var colisao = $CollisionShape2D

var esta_visivel = true

func _ready():
	# Configura como a plataforma começa baseada no atraso
	if atraso_inicial > 0.0:
		esta_visivel = false
		_atualizar_visual_e_fisica()
		timer.wait_time = atraso_inicial
	else:
		esta_visivel = true
		_atualizar_visual_e_fisica()
		timer.wait_time = tempo_ligada
	
	timer.start()

# Sinal do Timer (lembre-se de conectar a bolinha verde!)
func _on_timer_timeout():
	esta_visivel = !esta_visivel # Inverte o estado (se estava ligada, desliga)
	_atualizar_visual_e_fisica()
	
	# Ajusta o tempo do timer para o próximo ciclo
	if esta_visivel:
		timer.wait_time = tempo_ligada
	else:
		timer.wait_time = tempo_desligada
		
	timer.start()

func _atualizar_visual_e_fisica():
	sprite.visible = esta_visivel
	# set_deferred é necessário na Godot para desligar colisões de forma segura
	colisao.set_deferred("disabled", !esta_visivel)
