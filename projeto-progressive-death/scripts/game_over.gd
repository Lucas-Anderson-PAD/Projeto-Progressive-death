extends Control

# Tela de Game Over (aparece ao "Desistir" na pausa). O botão volta para a
# tela de início.

const CENA_INICIO := "res://cenas/menus/tela_inicio.tscn"


func _ready() -> void:
	$Voltar.pressed.connect(_voltar)


func _voltar() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(CENA_INICIO)
