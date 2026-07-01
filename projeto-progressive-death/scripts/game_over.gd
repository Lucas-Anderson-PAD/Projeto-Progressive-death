extends Control

# Tela de Game Over: aparece ao MORRER numa fase ou ao "Desistir" na pausa.
# "De novo" repete a fase onde estava; "Menu" volta para a tela de início.

const CENA_INICIO := "res://cenas/menus/tela_inicio.tscn"
const CENA_FASE1 := "res://cenas/fase1/fase1.tscn"


func _ready() -> void:
	$DeNovo.pressed.connect(_de_novo)
	$Voltar.pressed.connect(_voltar)


func _de_novo() -> void:
	get_tree().paused = false
	Inventario.resetar_vidas()
	var alvo: String = Inventario.cena_retry
	if alvo == "":
		alvo = CENA_FASE1
	get_tree().change_scene_to_file(alvo)


func _voltar() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(CENA_INICIO)
