extends CanvasLayer

@onready var key_label = $VBoxContainer/Label

func _ready():
	GameState.keys_updated.connect(_on_keys_updated)

func _on_keys_updated(current_count: int):
	key_label.text = "Chaves: X %d/7" % current_count
