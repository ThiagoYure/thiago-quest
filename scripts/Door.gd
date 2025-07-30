extends StaticBody2D

@export_multiline var dialogue_file : String
var dialogue_dict: Dictionary
var dialogue_lines: Array
var dialogue_active := false
var player_in_range := false

@onready var dialogue_box = get_tree().current_scene.get_node("DialogBox")

func _ready() -> void:
	$InteractiveArea.body_entered.connect(_on_body_entered)
	$InteractiveArea.body_exited.connect(_on_body_exited)
	_parse_dialogue()
	_load_dialogue("Default_dialogue")
	
	var dialogue_box = get_tree().current_scene.get_node("DialogBox")
	if dialogue_box:
		dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

func _parse_dialogue():
	var parsed = JSON.parse_string(dialogue_file)
	if parsed is Dictionary:
		dialogue_dict = parsed
	else:
		push_error("Erro ao converter JSON. Verifique a sintaxe.")

func _load_dialogue(type: String):
	dialogue_lines = dialogue_dict.get(type, [])

func _on_dialogue_finished():
	dialogue_active = false

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		if GameState.key_parts == 7 :
			queue_free()
		elif dialogue_box and not dialogue_active and not dialogue_box.visible:
			_load_dialogue("Default_dialogue")
			dialogue_box.show_dialogue(dialogue_lines)
			dialogue_active = true
