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
	# So some se realmente coube no inventario (senao fica para pegar depois).
	if Inventario.adicionar_item(icone):
		# Item capacete: equipa o jogador (permite nadar e muda a aparencia).
		if da_capacete and "tem_capacete" in body:
			body.tem_capacete = true
		queue_free()
