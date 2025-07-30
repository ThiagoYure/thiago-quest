extends CanvasLayer

func _ready():
	hide()
	$Timer.timeout.connect(_on_char_timer_timeout)

func show_notification():
	show()
	$AudioStreamPlayer2D.play()
	$Timer.start()

func _on_char_timer_timeout():
	hide()
