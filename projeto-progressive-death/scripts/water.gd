extends Area2D

# Se preenchido, esta área vira um PORTAL: ao o jogador entrar, ele é levado
# imediatamente para esta cena (em vez de funcionar como água de nadar).
# Vazio = comporta-se como água normal (ativa o nado no player).
@export_file("*.tscn") var portal_para: String = ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	# Só reage ao jogador (que tem a propriedade "water").
	if not ("water" in body):
		return

	# Portal: troca de cena imediatamente.
	# Deferido para não trocar a cena no meio do passo de física.
	if portal_para != "":
		get_tree().change_scene_to_file.call_deferred(portal_para)
		return

	# Água normal: ativa o nado.
	body.water = true

func _on_body_exited(body):
	if "water" in body:
		body.water = false
