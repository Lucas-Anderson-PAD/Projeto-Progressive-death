extends Area2D

func _on_body_entered(body):
	# Encostar no espinho = morte: perde os itens do inventário e reinicia a fase.
	if body.is_in_group("player"):
		Inventario.limpar()
		get_tree().reload_current_scene()
