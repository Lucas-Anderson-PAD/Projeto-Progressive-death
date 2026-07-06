extends Node2D

@export_category("Referências Gerais")
@export var camera_da_fase: Camera2D

@export_category("Estágio 1 - Aves")
@export var cena_ave: PackedScene
@export var tempo_spawn_aves: float = 3.5 # Uma ave a cada 3.5 segundos
var max_num_aves: int = 0 #limite de aves 

@export_category("Estágio 2 - Destroços")
# Clique em "Array", mude o tipo para "PackedScene" e adicione seus destroços na lista no Inspetor
@export var lista_de_destrocos: Array[PackedScene]
@export var tempo_spawn_destrocos: float = 1.5 # Um destroço a cada 1.5 segundos

var timer_aves: Timer
var timer_destrocos: Timer

func _ready() -> void:
	# Cria e configura o cronômetro das aves automaticamente
	timer_aves = Timer.new()
	timer_aves.wait_time = tempo_spawn_aves
	timer_aves.timeout.connect(_spawnar_ave)
	add_child(timer_aves)
	
	# Cria e configura o cronômetro do destroços automaticamente
	timer_destrocos = Timer.new()
	timer_destrocos.wait_time = tempo_spawn_destrocos
	timer_destrocos.timeout.connect(_spawnar_destroco)
	add_child(timer_destrocos)

# --- FUNÇÕES DE COMANDO (Chamadas pelo Diretor do Cenário) ---

func iniciar_aves() -> void:
	timer_aves.start()
	print("GERADOR: Começou a criar aves.")

func parar_aves() -> void:
	timer_aves.stop()
	print("GERADOR: Parou de criar aves.")

func iniciar_destrocos() -> void:
	timer_destrocos.start()
	print("GERADOR: Começou a criar destroços.")

func parar_destrocos() -> void:
	timer_destrocos.stop()
	print("GERADOR: Parou de criar destroços.")


# --- LÓGICA DE SPAWN BASEADA NA CÂMERA ---

func _spawnar_ave() -> void:
	if cena_ave == null or not camera_da_fase: return
	
	if max_num_aves > 2:
		return
	max_num_aves+=1
	var nova_ave = cena_ave.instantiate()

	var tela_x = get_viewport_rect().size.x
	var tela_y = get_viewport_rect().size.y
	var zoom = camera_da_fase.zoom
	var centro = camera_da_fase.get_screen_center_position()
	
	var limite_esq = centro.x - (tela_x / 2) / zoom.x
	var limite_dir = centro.x + (tela_x / 2) / zoom.x
	var limite_topo = centro.y - (tela_y / 2) / zoom.y
	
	# Posição X aleatória dentro da visão do jogador
	var pos_x = randf_range(limite_esq + 50, limite_dir - 50)
	# Nasce um pouco abaixo do topo da tela para o jogador vê-la surgir do topo
	var pos_y = limite_topo -60 
	
	nova_ave.global_position = Vector2(pos_x, pos_y)
	nova_ave.camera = camera_da_fase # Passa a referência da câmera para a ave quicar nas bordas
	
	# Adiciona a ave na cena principal como irmã do gerador
	get_parent().add_child(nova_ave)

func _spawnar_destroco() -> void:
	if lista_de_destrocos.is_empty() or not camera_da_fase: return
	
	# Escolhe um destroço aleatório da lista do Inspetor
	var cena_sorteada = lista_de_destrocos.pick_random()
	if cena_sorteada == null: return
	
	var novo_destroco = cena_sorteada.instantiate()
	
	var tela_x = get_viewport_rect().size.x
	var tela_y = get_viewport_rect().size.y
	var zoom = camera_da_fase.zoom
	var centro = camera_da_fase.get_screen_center_position()
	
	var limite_esq = centro.x - (tela_x / 2) / zoom.x
	var limite_dir = centro.x + (tela_x / 2) / zoom.x
	var limite_baixo = centro.y + (tela_y / 2) / zoom.y
	
	var pos_x = randf_range(limite_esq + 50, limite_dir - 50)
	# Como a câmera desce, os destroços nascem escondidos ABAIXO da tela
	# Dando a impressão perfeita que eles estão fixos e a câmera os está alcançando
	var pos_y = limite_baixo + 150 
	
	novo_destroco.global_position = Vector2(pos_x, pos_y)
	
	get_parent().add_child(novo_destroco)
