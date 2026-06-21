@tool
extends Area2D

# Guarda, entre trocas de cena, em qual portal de SAIDA o jogador deve aparecer.
# (static = sobrevive a troca de cena, sem precisar de autoload.)
static var id_destino_pendente: String = ""

enum Cor { VERDE, ROXO }

# ------------------------ Aparencia ------------------------
# Escolha no Inspetor qual portal usar; a imagem troca sozinha.
@export var cor: Cor = Cor.VERDE:
	set(value):
		cor = value
		_atualizar_textura()

@export var textura_verde: Texture2D
@export var textura_roxo: Texture2D

# ------------------------ Ligacao entre portais ------------------------
# Identificador unico deste portal (ex.: "A", "saida_fase2").
@export var id_portal: String = ""

# FALSE = ENTRADA: ao o jogador entrar, leva-o ao destino.
# TRUE  = SAIDA: apenas o ponto de chegada (nao teleporta).
# Convencao do projeto: Verde = entrada (false), Roxo = saida (true).
@export var eh_saida: bool = false

@export_group("Destino (apenas para ENTRADA)")
# Cena de destino. Deixe VAZIO para teleportar dentro da MESMA cena.
@export_file("*.tscn") var cena_destino: String = ""
# id do portal de SAIDA onde o jogador deve reaparecer.
@export var id_destino: String = ""

@export_group("Animacao")
@export var animar: bool = true
@export var fps_animacao: float = 12.0
@export var total_frames: int = 22

@onready var sprite: Sprite2D = $Sprite2D

var _tempo: float = 0.0


func _ready() -> void:
	_atualizar_textura()

	# No editor para por aqui (so atualiza a imagem de previa).
	if Engine.is_editor_hint():
		return

	body_entered.connect(_on_body_entered)

	if eh_saida:
		add_to_group("portal_saida")
		# Se o jogador acabou de chegar por este portal, posiciona-o aqui.
		if id_portal != "" and id_portal == id_destino_pendente:
			id_destino_pendente = ""
			_posicionar_jogador.call_deferred()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not animar or sprite == null:
		return
	# Avanca os frames do sprite sheet em loop (a "abertura"/giro do portal).
	_tempo += delta * fps_animacao
	sprite.frame = int(_tempo) % maxi(total_frames, 1)


func _atualizar_textura() -> void:
	if sprite == null:
		return
	sprite.texture = textura_roxo if cor == Cor.ROXO else textura_verde


func _on_body_entered(body: Node) -> void:
	# So a ENTRADA reage, e somente ao jogador (grupo "player").
	if eh_saida:
		return
	if not body.is_in_group("player"):
		return

	# Marca em qual saida o jogador deve reaparecer.
	id_destino_pendente = id_destino

	var cena_atual := get_tree().current_scene.scene_file_path
	if cena_destino != "" and cena_destino != cena_atual:
		# Portal para OUTRA cena (deferido p/ nao trocar cena durante a fisica).
		get_tree().change_scene_to_file.call_deferred(cena_destino)
	else:
		# Teleporte dentro da MESMA cena: vai direto para a saida ligada.
		_teleportar_local(body as Node2D)


func _teleportar_local(jogador: Node2D) -> void:
	if jogador == null:
		return
	for p in get_tree().get_nodes_in_group("portal_saida"):
		if p.id_portal == id_destino:
			jogador.global_position = p.global_position
			id_destino_pendente = ""
			return


func _posicionar_jogador() -> void:
	var jogador := get_tree().get_first_node_in_group("player") as Node2D
	if jogador:
		jogador.global_position = global_position
