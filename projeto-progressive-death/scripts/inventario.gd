extends CanvasLayer

# Inventario global (autoload): fica sempre no canto superior esquerdo, guarda
# até 3 itens e deixa equipar UM por vez pelas teclas 1, 2 e 3.
# - Apertar a tecla de um slot equipa o item; apertar de novo (ou outro slot)
#   desequipa / troca. Só um item equipado por vez.
# - O capacete, quando equipado, deixa o jogador nadar e muda a aparência.
# - Ao morrer, o inventário é esvaziado (limpar()).

const MAX_SLOTS := 3

# Retângulos dos 3 slots (coords locais do Painel) para a moldura de seleção.
const SLOT_RECTS := [
	Rect2(20, 16, 60, 64),
	Rect2(88, 16, 60, 64),
	Rect2(156, 16, 60, 64),
]

@onready var _slots: Array = [$Painel/Slot0, $Painel/Slot1, $Painel/Slot2]
@onready var _selecao: ColorRect = $Painel/Selecao

# Cada item é um dicionário: { "icone": Texture2D, "da_capacete": bool }
var itens: Array = []
var equipado := -1   # índice do slot equipado (-1 = nenhum)


func _ready() -> void:
	_atualizar()


func _process(_delta: float) -> void:
	# Mantém o efeito do item equipado aplicado ao jogador atual (inclusive
	# após troca de cena). Sem nada equipado, garante tem_capacete = false.
	var jogador = get_tree().get_first_node_in_group("player")
	if jogador and "tem_capacete" in jogador:
		jogador.tem_capacete = _capacete_equipado()


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
func adicionar_item(icone: Texture2D, da_capacete: bool = false) -> bool:
	if icone == null or itens.size() >= MAX_SLOTS:
		return false
	itens.append({ "icone": icone, "da_capacete": da_capacete })
	_atualizar()
	return true


func esta_cheio() -> bool:
	return itens.size() >= MAX_SLOTS


# Esvazia o inventário e desequipa tudo (chamado ao morrer).
func limpar() -> void:
	itens.clear()
	equipado = -1
	_atualizar()


func _capacete_equipado() -> bool:
	return equipado >= 0 and equipado < itens.size() and itens[equipado].get("da_capacete", false)


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
