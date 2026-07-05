@tool
extends Area2D

# Item coletavel: ao o jogador encostar, o icone vai para uma caixinha do
# inventario e o item some. Defina o "icone" no Inspetor para trocar o item.

@export var icone: Texture2D:
	set(value):
		icone = value
		_aplicar_icone()

# Se true, ao pegar este item o jogador ganha o capacete (tem_capacete = true):
# muda a aparência e passa a poder nadar na água.
@export var da_capacete: bool = false

# Se true, ao pegar este item o jogador ganha a BOTA (tem_bota = true): muda a
# aparencia de andar/pulo e permite matar inimigos pulando em cima deles.
@export var da_bota: bool = false

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_aplicar_icone()

	# No editor para por aqui (so mostra o icone na previa).
	if Engine.is_editor_hint():
		return

	body_entered.connect(_on_body_entered)


func _aplicar_icone() -> void:
	if sprite:
		sprite.texture = icone


func _on_body_entered(body: Node) -> void:
	# So o jogador (grupo "player") coleta.
	if not body.is_in_group("player"):
		return
	# Guarda o item no inventario (com a info de capacete). NAO equipa sozinho:
	# o jogador equipa pelas teclas 1/2/3.
	if Inventario.adicionar_item(icone, da_capacete, da_bota):
		queue_free()
