extends Node

# Música de fundo global (autoload "Musica").
# - Toca "musica_fundo" em todas as fases (e menus).
# - Faz crossfade para "musica_agua" quando o jogador está na ÁGUA ou na
#   FASE SECRETA; volta para a de fundo ao sair.
# Os dois players tocam em loop o tempo todo; só o volume alterna (crossfade),
# então cada faixa mantém sua posição. Continua tocando durante a pausa.

const CAMINHO_FUNDO := "res://sons/musica_fundo.mp3"
const CAMINHO_AGUA := "res://sons/musica_agua.mp3"

const VOL_ON := 0.0      # dB audível
const VOL_OFF := -60.0   # dB praticamente mudo
const FADE := 80.0       # dB por segundo no crossfade

var _fundo: AudioStreamPlayer
var _agua: AudioStreamPlayer


func _ready() -> void:
	# Continua tocando mesmo com o jogo pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS

	_fundo = _criar_player(CAMINHO_FUNDO, VOL_ON)
	_agua = _criar_player(CAMINHO_AGUA, VOL_OFF)


func _criar_player(caminho: String, vol: float) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	var s: AudioStream = load(caminho)
	if s != null:
		# Faz a faixa repetir em loop (mp3 -> AudioStreamMP3 tem 'loop').
		if "loop" in s:
			s.loop = true
		p.stream = s
	p.volume_db = vol
	add_child(p)
	if s != null:
		p.play()
	return p


func _process(delta: float) -> void:
	var submerso := _em_agua_ou_secreta()
	var alvo_agua := VOL_ON if submerso else VOL_OFF
	var alvo_fundo := VOL_OFF if submerso else VOL_ON
	if _agua != null:
		_agua.volume_db = move_toward(_agua.volume_db, alvo_agua, FADE * delta)
	if _fundo != null:
		_fundo.volume_db = move_toward(_fundo.volume_db, alvo_fundo, FADE * delta)


# True quando o jogador está na água OU a cena atual é a fase secreta.
func _em_agua_ou_secreta() -> bool:
	var cena := get_tree().current_scene
	if cena != null and "fase_secreta" in cena.scene_file_path:
		return true
	var jogador = get_tree().get_first_node_in_group("player")
	if jogador != null and "water" in jogador and jogador.water:
		return true
	return false
