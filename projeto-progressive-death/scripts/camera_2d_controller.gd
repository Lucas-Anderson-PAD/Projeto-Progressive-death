extends Camera2D

const VELOCIDADE_QUEDA = 400.0 # Ajuste para o ritmo da fase

func _physics_process(delta):
	# A câmera desce independentemente do que o jogador faz
	position.y += VELOCIDADE_QUEDA * delta
