extends CanvasLayer

# Inventario global (autoload): fica sempre no canto superior esquerdo, guarda
# até 3 itens e deixa equipar UM por vez pelas teclas 1, 2 e 3.
# - Apertar a tecla de um slot equipa o item; apertar de novo (ou outro slot)
#   desequipa / troca. Só um item equipado por vez.
# - O capacete, quando equipado, deixa o jogador nadar e muda a aparência.
# - Ao morrer, o inventário é esvaziado (limpar()).

const MAX_SLOTS := 3
const MAX_VIDAS := 3
const INVULN_TEMPO := 1.0   # segundos de invulnerabilidade após levar dano

# Retângulos dos 3 slots (coords locais do Painel) para a moldura de seleção.
const SLOT_RECTS := [
	Rect2(20, 16, 60, 64),
	Rect2(88, 16, 60, 64),
	Rect2(156, 16, 60, 64),
]

@onready var _slots: Array = [$Painel/Slot0, $Painel/Slot1, $Painel/Slot2]
@onready var _selecao: ColorRect = $Painel/Selecao
@onready var _coracoes: Array = [$Coracao0, $Coracao1, $Coracao2]

# Cada item é um dicionário: { "icone": Texture2D, "da_capacete": bool }
var itens: Array = []
var equipado := -1   # índice do slot equipado (-1 = nenhum)

# Fase que o botão "De novo" do game over vai repetir (setada em morrer()).
var cena_retry := "res://cenas/fase1/fase1.tscn"

# Vidas (corações). Persiste entre fases; só volta a 3 ao (re)começar a partida.
var vidas := MAX_VIDAS
var _invuln := 0.0    # segundos restantes de invulnerabilidade
var _tex_cheio: Texture2D
var _tex_vazio: Texture2D


func _ready() -> void:
	_tex_cheio = load("res://sprites/ui/coracao_cheio.png")
	_tex_vazio = load("res://sprites/ui/coracao_vazio.png")
	_atualizar()
	_atualizar_coracoes()


func _process(delta: float) -> void:
	# Conta a invulnerabilidade pós-dano.
	if _invuln > 0.0:
		_invuln = maxf(_invuln - delta, 0.0)

	# Esconde o HUD do inventário nas telas de menu (cenas/menus/): início/game over.
	visible = not _em_menu()

	# Mantém o efeito do item equipado aplicado ao jogador atual (inclusive
	# após troca de cena). Sem nada equipado, garante tem_capacete = false.
	var jogador = get_tree().get_first_node_in_group("player")
	if jogador and "tem_capacete" in jogador:
		jogador.tem_capacete = _capacete_equipado()
	if jogador and "tem_bota" in jogador:
		jogador.tem_bota = _bota_equipado()


# True quando a cena atual é uma tela de menu (pasta cenas/menus/).
func _em_menu() -> bool:
	var cena := get_tree().current_scene
	if cena == null:
		return false
	return cena.scene_file_path.begins_with("res://cenas/menus/")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1, KEY_KP_1: _usar_slot(0)
			KEY_2, KEY_KP_2: _usar_slot(1)
			KEY_3, KEY_KP_3: _usar_slot(2)


# Tecla do slot: equipa esse item; se já estava equipado, desequipa (toggle).
# Equipar um slot diferente desequipa o anterior (só um por vez).
func _usar_slot(i: int) -> void:
	if i < 0 or i >= itens.size():
		return
	equipado = -1 if equipado == i else i
	_atualizar()


# Adiciona o item na primeira caixinha livre. NÃO equipa automaticamente.
func adicionar_item(icone: Texture2D, da_capacete: bool = false, da_bota: bool = false) -> bool:
	if icone == null or itens.size() >= MAX_SLOTS:
		return false
	itens.append({ "icone": icone, "da_capacete": da_capacete, "da_bota": da_bota })
	_atualizar()
	return true


func esta_cheio() -> bool:
	return itens.size() >= MAX_SLOTS


# Esvazia o inventário e desequipa tudo (chamado ao morrer).
func limpar() -> void:
	itens.clear()
	equipado = -1
	_atualizar()


# Mata o jogador: limpa o inventário, guarda a fase para repetir e abre a tela
# de Game Over (antes recarregava a fase direto; agora passa pelo Game Over).
func morrer() -> void:
	limpar()
	registrar_retry()
	# Deferido: morrer() pode ser chamado de dentro da física (piranha/perigos),
	# e trocar de cena durante o flush de física dá erro/free indevido.
	get_tree().change_scene_to_file.call_deferred("res://cenas/menus/game_over.tscn")


# Guarda a fase atual como a que o botão "De novo" do game over vai repetir.
# A fase secreta (e cenas sem arquivo) voltam para a fase 1.
func registrar_retry() -> void:
	var cena := get_tree().current_scene
	var caminho := cena.scene_file_path if cena != null else ""
	cena_retry = "res://cenas/fase1/fase1.tscn" if (caminho == "" or "fase_secreta" in caminho) else caminho


# Perde 1 coração (piranha, espinho da fase 2, destroço, tronco, ave). Durante a
# invulnerabilidade ignora novos hits; ao zerar os corações, morre de vez.
func perder_vida() -> void:
	if _invuln > 0.0 or vidas <= 0:
		return
	vidas -= 1
	_atualizar_coracoes()
	if vidas <= 0:
		morrer()
	else:
		_invuln = INVULN_TEMPO


# Restaura os 3 corações. Só ao (re)começar a partida (Iniciar / De novo),
# nunca ao trocar de fase.
func resetar_vidas() -> void:
	vidas = MAX_VIDAS
	_invuln = 0.0
	_atualizar_coracoes()


# Mostra corações cheios até 'vidas' e vazios no resto.
func _atualizar_coracoes() -> void:
	for i in range(MAX_VIDAS):
		if i < _coracoes.size():
			_coracoes[i].texture = _tex_cheio if i < vidas else _tex_vazio


func _capacete_equipado() -> bool:
	return equipado >= 0 and equipado < itens.size() and itens[equipado].get("da_capacete", false)


func _bota_equipado() -> bool:
	return equipado >= 0 and equipado < itens.size() and itens[equipado].get("da_bota", false)


func _atualizar() -> void:
	for i in range(MAX_SLOTS):
		_slots[i].texture = itens[i]["icone"] if i < itens.size() else null

	# Moldura de seleção sobre o slot equipado.
	if equipado >= 0 and equipado < SLOT_RECTS.size():
		var r: Rect2 = SLOT_RECTS[equipado]
		_selecao.position = r.position
		_selecao.size = r.size
		_selecao.visible = true
	else:
		_selecao.visible = false
