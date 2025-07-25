extends CharacterBody2D

@export var dialogue_lines: Array = [
	{ "speaker": "NPC", "text": "Olá, viajante! Bem-vindo ao nosso vilarejo." },
	{ "speaker": "Player", "text": "Obrigado! Parece um lugar pacífico." },
	{ "speaker": "NPC", "text": "Fique o tempo que quiser." }
]

var player_in_range := false
var dialogue_active = false

func _ready():
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)
	
	var dialogue_box = get_tree().current_scene.get_node("DialogBox")
	if dialogue_box:
		dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

func _on_body_entered(body):
	if body.name == "Player": # ou use `body.is_in_group("player")`
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false

func _on_dialogue_finished():
	dialogue_active = false

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		var dialogue_box = get_tree().current_scene.get_node("DialogBox")
		if dialogue_box and not dialogue_active and not dialogue_box.visible:
			dialogue_box.show_dialogue(dialogue_lines)
			dialogue_active = true
