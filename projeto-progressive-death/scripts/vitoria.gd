extends Control

# Tela de VITÓRIA. O botão Reiniciar volta para a tela de início.
#
# OBS: esta cena ainda NÃO é disparada por nada (sem trigger de vitória, como
# pedido). Quando houver uma condição de vitória, é só chamar:
#   get_tree().change_scene_to_file("res://cenas/menus/vitoria.tscn")

const CENA_INICIO := "res://cenas/menus/tela_inicio.tscn"


func _ready() -> void:
	$Reiniciar.pressed.connect(_reiniciar)


func _reiniciar() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(CENA_INICIO)
