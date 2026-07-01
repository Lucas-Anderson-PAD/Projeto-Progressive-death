extends Node2D

@onready var zona_de_dano = $ZonaDeDano

func _ready() -> void:
	# Conecta o sinal de colisão da área de espinhos via código
	zona_de_dano.body_entered.connect(_on_espinhos_body_entered)

func _on_espinhos_body_entered(body: Node2D) -> void:
	# Verifica se quem encostou no espinho foi o jogador
	if body is PlayerFase2:
		print("O Cardeal bateu nos espinhos!")
		
		# Empurra o jogador de volta para o centro/cima para ele não ficar preso dentro do espinho
		body.velocity.y = -800.0 # Quica para cima
		
		# chamar função de dano que existe no script do Player
		# Exemplo: body.tomar_dano(1)
