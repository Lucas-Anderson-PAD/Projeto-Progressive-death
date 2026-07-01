extends Control

# Tela de início: o botão Iniciar carrega a fase 1.

const CENA_FASE1 := "res://cenas/fase1/fase1.tscn"


func _ready() -> void:
	$Iniciar.pressed.connect(_iniciar)


func _iniciar() -> void:
	# Garante que o jogo não comece pausado.
	get_tree().paused = false
	get_tree().change_scene_to_file(CENA_FASE1)
