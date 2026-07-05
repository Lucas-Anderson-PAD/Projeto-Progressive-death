extends Control

# Tela de VITÓRIA. "Jogar novamente" começa uma partida NOVA direto na fase 1
# (não volta para a tela de início).
#
# OBS: esta cena ainda NÃO é disparada por nada além do portal dourado. Para
# mostrar a vitória de outro jeito, chame:
#   get_tree().change_scene_to_file("res://cenas/menus/vitoria.tscn")

const CENA_FASE1 := "res://cenas/fase1/fase1.tscn"


func _ready() -> void:
	$Reiniciar.pressed.connect(_jogar_novamente)


func _jogar_novamente() -> void:
	get_tree().paused = false
	Inventario.limpar()         # partida nova: começa sem itens
	Inventario.resetar_vidas()  # e com os 3 corações
	get_tree().change_scene_to_file(CENA_FASE1)
