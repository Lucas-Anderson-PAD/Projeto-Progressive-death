extends Node2D

@export_category("Controle do Diretor")
@export var largura_da_fase: float = 1152.0 
@export var camera: Camera2D

@export var gerador_de_desafios: Node2D 

@export_category("Estágio 1 - Céu (Pôr do Sol)")
@export var camada01: Texture2D
@export var camada01_repeticao: Texture2D
@export var repeticoes_estag_1: int = 2

@export_category("Estágio 2 - Abismo")
@export var camada1: Texture2D
@export var camada1_repeticao: Texture2D
@export var repeticoes_estag_2: int = 3

@export_category("Estágio 3 - Fundo")
@export var camada2: Texture2D
@export var camada2_repeticao: Texture2D
@export var repeticoes_camada2: int = 2

@export_category("Estágio 3 - Espinhos (Físicos)")
@export var cena_estagio_3: PackedScene

var altura_atual_y: float = 0.0

# --- MARCADORES DO DIRETOR ---
var inicio_abismo_y: float = 0.0
var inicio_espinhos_y: float = 0.0

enum FaseEstado { AVES, DESTROCOS, ESPINHOS }
var estado_atual = FaseEstado.AVES

func _ready() -> void:
	construir_fase()
	
	# Ao nascer, a fase sempre começa no estado de Aves
	if gerador_de_desafios:
		gerador_de_desafios.iniciar_aves()

func _process(_delta: float) -> void:
	if not camera or not gerador_de_desafios: return
	
	var y_camera = camera.global_position.y
	
	# O Diretor analisa a altura da câmera e muda o cenário de acordo
	match estado_atual:
		FaseEstado.AVES:
			if y_camera >= inicio_abismo_y:
				estado_atual = FaseEstado.DESTROCOS
				gerador_de_desafios.parar_aves()
				gerador_de_desafios.iniciar_destrocos()
				print("Entrou no Abismo! Parando aves, iniciando destroços.")
				
		FaseEstado.DESTROCOS:
			if y_camera >= inicio_espinhos_y:
				estado_atual = FaseEstado.ESPINHOS
				gerador_de_desafios.parar_destrocos()
				print("Entrou na Caverna! Parando destroços, iniciando corredor de espinhos.")
				
		FaseEstado.ESPINHOS:
			# Os espinhos já estão no cenário como paredes físicas, então o gerador não precisa instanciar nada.
			pass


# ==========================================
# CONSTRUÇÃO DO CENÁRIO E MARCAÇÃO DE LINHAS
# ==========================================

func construir_fase() -> void:
	# --- ESTÁGIO 1: PÔR DO SOL ---
	adicionar_imagem(camada01, -10)
	for i in range(repeticoes_estag_1):
		adicionar_imagem(camada01_repeticao, -10)
		
	# Grava a altura exata onde o estágio 1 termina e o 2 começa!
	inicio_abismo_y = altura_atual_y
		
	# --- ESTÁGIO 2: ABISMO ---
	adicionar_transicao(camada1, -5)
	for i in range(repeticoes_estag_2):
		adicionar_imagem(camada1_repeticao, -5)
		
	# Grava a altura exata onde o estágio 2 termina e os espinhos começam!
	inicio_espinhos_y = altura_atual_y
		
	# --- ESTÁGIO 3: ESPINHOS E FUNDO ---
	adicionar_transicao(camada2, -2)
	for i in range(repeticoes_camada2):
		adicionar_imagem(camada2_repeticao, -2)
		
	# Colisões reais da caverna
	adicionar_cena_transicao(cena_estagio_3, 0)


# =======================
# FUNÇÕES DE RENDERIZAÇÃO
# =======================

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

func adicionar_cena_transicao(cena: PackedScene, z_index_valor: int) -> void:
	if cena == null: return
	var instancia = cena.instantiate()
	var sprite_topo = instancia.get_node_or_null("Sprite2D")
	if not sprite_topo or not sprite_topo.texture: return
	var textura = sprite_topo.texture
	var fator_escala = largura_da_fase / textura.get_width()
	altura_atual_y -= textura.get_height() * fator_escala
	instancia.z_index = z_index_valor
	instancia.position = Vector2(0.0, altura_atual_y)
	instancia.scale = Vector2(fator_escala, fator_escala)
	add_child(instancia)
