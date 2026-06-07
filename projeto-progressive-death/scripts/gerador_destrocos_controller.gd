extends Node2D

# Isso cria uma caixinha no Inspetor do Godot onde você pode arrastar suas cenas!
@export var lista_de_obstaculos: Array[PackedScene]

# Precisamos saber onde a câmera está para spawnar os obstáculos abaixo dela
@export var camera_da_fase: Camera2D 

# Limites da sua tela no eixo X para o obstáculo não nascer dentro da parede
const LIMITE_ESQUERDO = 100
const LIMITE_DIREITO = 900 

func _on_timer_timeout() -> void:
	if lista_de_obstaculos.is_empty():
		return
		
	var cena_sorteada = lista_de_obstaculos.pick_random()
	var novo_obstaculo = cena_sorteada.instantiate()
	var posicao_x_aleatoria = randf_range(LIMITE_ESQUERDO, LIMITE_DIREITO)
	
	# Usamos global_position para ter a coordenada exata no mundo
	var posicao_y_escondida = camera_da_fase.position.y + 800 
	
	# Passamos para o global_position do obstáculo também
	novo_obstaculo.global_position = Vector2(posicao_x_aleatoria, posicao_y_escondida)
	
	add_child(novo_obstaculo)
	
	# O TESTE DEFINITIVO: Isso vai escrever no painel "Saída" (Output) do Godot
	print("Spawnou um obstáculo na posição global: ", novo_obstaculo.global_position)
