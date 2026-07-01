extends Area2D

# Agua: detecta o jogador (via propriedade "water") e aplica um shader de agua
# animada ao ColorRect visual, mantendo a cor/transparencia de cada instancia.
# A animacao aparece ao RODAR o jogo.

const SHADER_AGUA := preload("res://shaders/agua.gdshader")


func _ready() -> void:
	_aplicar_shader_agua()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


# Coloca o shader animado em cada ColorRect filho, passando a cor original.
func _aplicar_shader_agua() -> void:
	for filho in get_children():
		if filho is ColorRect:
			var mat := ShaderMaterial.new()
			mat.shader = SHADER_AGUA
			mat.set_shader_parameter("cor_base", filho.color)
			filho.material = mat
			# Desenha a agua POR CIMA do que esta dentro dela (piranha, jogador),
			# dando o efeito de estar submerso.
			filho.z_index = 1


func _on_body_entered(body):
	if "water" in body:
		body.water = true


func _on_body_exited(body):
	if "water" in body:
		body.water = false
