extends AnimatableBody2D

@export_category("Configurações da Coluna")
@export var tamanho_coluna: int = 10 ## Quantidade total de blocos
@export var delay_espera: float = 2.0 ## Tempo parada antes de subir/descer
@export var velocidade: float = 150.0 ## Velocidade do movimento
@export var distancia_subida: float = 300.0 ## Quantos pixels ela vai subir

@onready var sprite = $Sprite2D
@onready var colisao = $CollisionShape2D
@onready var timer = $Timer

var posicao_inicial: Vector2
var subindo: bool = true
var movendo: bool = false

func _ready():
	posicao_inicial = global_position
	gerar_coluna()
	
	# Configura o timer para o delay inicial
	timer.wait_time = delay_espera
	timer.one_shot = true
	timer.start()

func gerar_coluna():
	# 1. Usamos get_rect().size.y para pegar o tamanho exato do corte na tela
	var altura_bloco = sprite.get_rect().size.y * abs(sprite.scale.y)
	
	# 2. Clona o sprite para formar a coluna
	for i in range(1, tamanho_coluna):
		var novo_sprite = sprite.duplicate()
		
		# O sinal de MENOS (-=) constrói os blocos PARA CIMA, empilhando no topo
		novo_sprite.position.y -= altura_bloco * i 
		add_child(novo_sprite)
		
	# 3. Ajusta a caixa de colisão para cobrir toda a coluna empilhada
	var nova_forma = RectangleShape2D.new()
	nova_forma.size = Vector2(colisao.shape.size.x, altura_bloco * tamanho_coluna)
	colisao.shape = nova_forma
	
	# Desloca o centro da colisão PARA CIMA para cobrir os blocos novos
	colisao.position.y -= (altura_bloco * (tamanho_coluna - 1)) / 2.0

func _physics_process(delta):
	if not movendo:
		return
		
	# Define até onde a coluna deve ir
	var destino_y = posicao_inicial.y - distancia_subida if subindo else posicao_inicial.y
	
	if subindo:
		global_position.y -= velocidade * delta
		if global_position.y <= destino_y:
			finalizar_movimento(destino_y)
	else:
		global_position.y += velocidade * delta
		if global_position.y >= destino_y:
			finalizar_movimento(destino_y)

func finalizar_movimento(destino_y):
	global_position.y = destino_y # Crava a posição exata para não passar do limite
	movendo = false
	subindo = not subindo # Inverte a direção
	
	# Inicia o timer para a próxima ação
	timer.wait_time = delay_espera
	timer.start()

func _on_timer_timeout():
	movendo = true
