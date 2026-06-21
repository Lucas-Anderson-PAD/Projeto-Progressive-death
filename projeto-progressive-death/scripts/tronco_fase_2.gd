extends Area2D

var velocidade_queda: float

func _ready():
	# Define uma velocidade aleatória assim que o objeto nasce.
	# IMPORTANTE: Se a câmera desce a 400 de velocidade,
	# e o obstáculo cai entre 100 e 300, a câmera vai "alcançar" o obstáculo,
	# dando a ilusão de que ele está suspenso ou caindo devagar.
	velocidade_queda = randf_range(100.0, 300.0) 

func _physics_process(delta: float) -> void:
	# O obstáculo cai (vai para baixo no eixo Y)
	position.y += velocidade_queda * delta

# Sinal do VisibleOnScreenNotifier2D que você deve conectar
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free() # Destrói o objeto quando a câmera passar por ele

func _on_body_entered(body: Node2D) -> void:
	# Verifica se o corpo que bateu está no grupo "Player"
	if body is PlayerFase2:
		print("O JOGADOR BATEU NO OBSTÁCULO!")
		
		queue_free()
