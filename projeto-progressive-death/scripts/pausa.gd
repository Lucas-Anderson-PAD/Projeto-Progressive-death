extends CanvasLayer

# UI global de PAUSA (autoload). Botão de pausa no topo-centro; ao pausar,
# mostra o menu com Continuar e Desistir. Aparece só nas fases (some nas telas
# de menu, em cenas/menus/). Roda com PROCESS_MODE_ALWAYS para continuar
# funcionando com a árvore pausada.

const CENA_GAME_OVER := "res://cenas/menus/game_over.tscn"

@onready var botao_pausa: TextureButton = $BotaoPausa
@onready var menu: Control = $MenuPausa


func _ready() -> void:
	# Continua processando/desenhando mesmo com o jogo pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	menu.visible = false
	botao_pausa.pressed.connect(_pausar)
	$MenuPausa/Continuar.pressed.connect(_continuar)
	$MenuPausa/Desistir.pressed.connect(_desistir)


func _process(_delta: float) -> void:
	# Só mostra a UI de pausa dentro das fases (nunca nas telas de menu).
	if not _em_jogo():
		botao_pausa.visible = false
		if menu.visible:
			menu.visible = false
		return
	botao_pausa.visible = not get_tree().paused


func _unhandled_input(event: InputEvent) -> void:
	# Tecla de pausa (Esc) também alterna o menu.
	if event.is_action_pressed("pausa") and _em_jogo():
		if get_tree().paused:
			_continuar()
		else:
			_pausar()


# True quando estamos numa fase (fora das telas de menu de cenas/menus/).
func _em_jogo() -> bool:
	var cena := get_tree().current_scene
	if cena == null:
		return false
	var caminho := cena.scene_file_path
	return caminho != "" and not caminho.begins_with("res://cenas/menus/")


func _pausar() -> void:
	if not _em_jogo():
		return
	get_tree().paused = true
	menu.visible = true
	botao_pausa.visible = false


func _continuar() -> void:
	get_tree().paused = false
	menu.visible = false


func _desistir() -> void:
	# Despausa antes de trocar de cena (senão o Game Over abriria pausado).
	get_tree().paused = false
	menu.visible = false
	get_tree().change_scene_to_file(CENA_GAME_OVER)
