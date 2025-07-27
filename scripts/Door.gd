extends StaticBody2D

@export var dialogue_file : Resource
var dialogue_lines: Array
var dialogue_active := false
var player_in_range := false

@onready var dialogue_box = get_tree().current_scene.get_node("DialogBox")

func _ready() -> void:
	$InteractiveArea.body_entered.connect(_on_body_entered)
	$InteractiveArea.body_exited.connect(_on_body_exited)
	
	_load_dialogue("Default_dialogue")
	
	var dialogue_box = get_tree().current_scene.get_node("DialogBox")
	if dialogue_box:
		dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

func _load_dialogue(type: String):
	if dialogue_file:
		var file = FileAccess.open(dialogue_file.resource_path, FileAccess.READ)
		if file == null:
			push_error("Não foi possível abrir: " + dialogue_file.resource_path)
		else :
			var content = file.get_as_text()
			file.close()
			var parsed = JSON.parse_string(content)
			dialogue_lines = parsed.get(type)

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
		if GameState.key_parts == 2 :
			queue_free()
		elif dialogue_box and not dialogue_active and not dialogue_box.visible:
			_load_dialogue("Default_dialogue")
			dialogue_box.show_dialogue(dialogue_lines)
			dialogue_active = true
