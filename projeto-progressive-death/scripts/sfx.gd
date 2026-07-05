extends Node

# Efeitos sonoros globais (autoload "Sfx"). Um pool de players toca sons curtos,
# podendo sobrepor. Os sons são carregados com load() (se ainda não importados,
# ficam null e simplesmente não tocam, sem quebrar nada).
#
# O som de CLIQUE é ligado AUTOMATICAMENTE a qualquer botão (BaseButton) da
# árvore — os que já existem e os que forem adicionados depois — então não é
# preciso editar cada cena de menu.
#
# Uso nos outros scripts:  Sfx.tocar("pulo")

const SONS := {
	"clique": "res://sons/sfx/clique.wav",
	"equipar": "res://sons/sfx/equipar.wav",
	"pulo": "res://sons/sfx/pulo.wav",
	"dano": "res://sons/sfx/dano.wav",
	"pisar": "res://sons/sfx/pisar.wav",
	"morte": "res://sons/sfx/morte.wav",
	"splash": "res://sons/sfx/splash.wav",
	"passo": "res://sons/sfx/passo.wav",
	"vitoria": "res://sons/sfx/vitoria.wav",
}

const N_PLAYERS := 8   # quantos sons podem tocar sobrepostos

var _streams := {}
var _players: Array[AudioStreamPlayer] = []
var _prox := 0


func _ready() -> void:
	# Continua tocando (e respondendo a cliques) mesmo com o jogo pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS

	for nome in SONS:
		var s: AudioStream = load(SONS[nome])
		if s != null:
			_streams[nome] = s

	for i in N_PLAYERS:
		var p := AudioStreamPlayer.new()
		p.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(p)
		_players.append(p)

	# Liga o clique a todos os botões: futuros (node_added) e os já existentes.
	get_tree().node_added.connect(_ao_adicionar_no)
	_varrer_botoes(get_tree().root)


# Toca um som pelo nome (chave de SONS). Ignora nomes desconhecidos / não
# importados. Usa o próximo player do pool (rodízio), permitindo sobreposição.
func tocar(nome: String, volume_db: float = 0.0) -> void:
	if not _streams.has(nome) or _players.is_empty():
		return
	var p := _players[_prox]
	_prox = (_prox + 1) % _players.size()
	p.stream = _streams[nome]
	p.volume_db = volume_db
	p.play()


func _ao_adicionar_no(no: Node) -> void:
	if no is BaseButton:
		_ligar_clique(no)


func _varrer_botoes(no: Node) -> void:
	if no is BaseButton:
		_ligar_clique(no)
	for filho in no.get_children():
		_varrer_botoes(filho)


func _ligar_clique(botao: BaseButton) -> void:
	if not botao.pressed.is_connected(_som_clique):
		botao.pressed.connect(_som_clique)


func _som_clique() -> void:
	tocar("clique")
