extends CanvasLayer

func _ready():
	hide()
	$Timer.timeout.connect(_on_char_timer_timeout)

func show_notification():
	show()
	AudioManager.play_sfx("res://assets/audio/SFX/sound1.wav")
	$Timer.start()

func _on_char_timer_timeout():
	hide()
