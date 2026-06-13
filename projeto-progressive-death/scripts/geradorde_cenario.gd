extends Node2D

@export_category("Configurações da Tela")
# Aumente ou diminua esse valor no Inspetor
@export var largura_da_fase: float = 1152.0 

@export_category("Estágio 1 - Céu")
@export var camada01: Texture2D
@export var camada01_repeticao: Texture2D
@export var repeticoes_estag_1: int = 2

@export_category("Estágio 2 - Boca do Abismo")
@export var camada1: Texture2D
@export var camada1_repeticao: Texture2D
@export var repeticoes_estag_2: int = 3

@export_category("Estágio 3 - Fundo e Espinhos")
@export var camada2: Texture2D
@export var camada2_repeticao: Texture2D
@export var repeticoes_camada2: int = 2
@export var camada3: Texture2D
@export var camada3_repeticao: Texture2D
@export var repeticoes_camada3: int = 4

var altura_atual_y: float = 0.0

func _ready() -> void:
	construir_fase()

func construir_fase() -> void:
	adicionar_imagem(camada01, -10)
	for i in range(repeticoes_estag_1):
		adicionar_imagem(camada01_repeticao, -10)
		
	adicionar_transicao(camada1, -5)
	for i in range(repeticoes_estag_2):
		adicionar_imagem(camada1_repeticao, -5)
		
	adicionar_transicao(camada2, 0)
	for i in range(repeticoes_camada2):
		adicionar_imagem(camada2_repeticao, 0)
		
	adicionar_transicao(camada3, 0)
	for i in range(repeticoes_camada3):
		adicionar_imagem(camada3_repeticao, 0)
		
	adicionar_imagem_invertida(camada3, 0)




func adicionar_imagem(textura: Texture2D, z_index_valor: int) -> void:
	if textura == null: return
	
	var fator_escala = largura_da_fase / textura.get_width()
	
	var novo_sprite = Sprite2D.new()
	novo_sprite.texture = textura
	novo_sprite.centered = false
	novo_sprite.z_index = z_index_valor
	novo_sprite.position = Vector2(0.0, altura_atual_y)
	
	novo_sprite.scale = Vector2(fator_escala, fator_escala)
	add_child(novo_sprite)
	
	altura_atual_y += textura.get_height() * fator_escala

func adicionar_transicao(textura: Texture2D, z_index_valor: int) -> void:
	if textura == null: return
	var fator_escala = largura_da_fase / textura.get_width()
	altura_atual_y -= textura.get_height() * fator_escala
	adicionar_imagem(textura, z_index_valor)

func adicionar_imagem_invertida(textura: Texture2D, z_index_valor: int) -> void:
	if textura == null: return
	var fator_escala = largura_da_fase / textura.get_width()
	
	var novo_sprite = Sprite2D.new()
	novo_sprite.texture = textura
	novo_sprite.centered = false
	novo_sprite.z_index = z_index_valor
	novo_sprite.position = Vector2(0.0, altura_atual_y)
	
	novo_sprite.scale = Vector2(fator_escala, fator_escala)
	novo_sprite.flip_v = true
	novo_sprite.flip_h = true
	add_child(novo_sprite)
