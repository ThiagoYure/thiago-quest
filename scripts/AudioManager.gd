extends Node

var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

var current_bgm: String = ""

var volume_bgm := 0.5
var volume_sfx := 0.8

func _ready():
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGM"
	bgm_player.bus = "Music"
	bgm_player.volume_db = linear_to_db(volume_bgm)
	add_child(bgm_player)

	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFX"
	sfx_player.bus = "SFX"
	sfx_player.volume_db = linear_to_db(volume_sfx)
	add_child(sfx_player)

func play_bgm(path: String, loop := true):
	if current_bgm == path and bgm_player.playing:
		return
	current_bgm = path
	var stream = load(path)
	if stream:
		if stream is AudioStream:
			if stream.has_method("set_loop"):
				stream.set_loop(loop)
			elif stream is AudioStreamOggVorbis:
				stream.loop = loop
		bgm_player.stream = stream
		bgm_player.play()


func stop_bgm():
	bgm_player.stop()
	current_bgm = ""

func play_sfx(path: String):
	var stream = load(path)
	if stream:
		sfx_player.stream = stream
		sfx_player.play()

func set_volume(bgm: float, sfx: float):
	volume_bgm = bgm
	volume_sfx = sfx
	bgm_player.volume_db = linear_to_db(volume_bgm)
	sfx_player.volume_db = linear_to_db(volume_sfx)
