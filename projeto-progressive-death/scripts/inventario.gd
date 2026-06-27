extends CanvasLayer

# Inventario global (autoload): fica sempre na tela, no canto superior esquerdo,
# e guarda os itens coletados em 3 caixinhas. Por ser autoload, sobrevive a
# troca de cena (os itens continuam la ao mudar de fase).

const MAX_SLOTS := 3

# As 3 caixinhas (TextureRect) onde os icones dos itens aparecem.
@onready var _slots: Array = [
	$Painel/Slot0,
	$Painel/Slot1,
	$Painel/Slot2,
]

# Texturas dos itens coletados, na ordem.
var itens: Array = []


func _ready() -> void:
	_atualizar()


# Coloca o item (sua textura) na primeira caixinha livre.
# Retorna true se coube, false se o inventario ja estava cheio.
func adicionar_item(icone: Texture2D) -> bool:
	if icone == null:
		return false
	if itens.size() >= MAX_SLOTS:
		return false
	itens.append(icone)
	_atualizar()
	return true


func esta_cheio() -> bool:
	return itens.size() >= MAX_SLOTS


# Atualiza a imagem de cada caixinha conforme os itens guardados.
func _atualizar() -> void:
	for i in range(MAX_SLOTS):
		_slots[i].texture = itens[i] if i < itens.size() else null
