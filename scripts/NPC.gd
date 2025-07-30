extends CharacterBody2D

@export_multiline var dialogue_file : String
@export var npc_name: String
@export var id: String
@export var textureHead: Texture2D
@export var textureBody: Texture2D

var dialogue_dict: Dictionary
var dialogue_lines: Array

var player_in_range := false
var dialogue_active = false
var question_answered = false
var notificated:=false
@onready var dialogue_box = get_tree().current_scene.get_node("DialogBox")
@onready var notification_box = get_tree().current_scene.get_node("NotificationBox")

func _ready():
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)
	_parse_dialogue()
	_load_dialogue("Default_dialogue")
	
	var dialogue_box = get_tree().current_scene.get_node("DialogBox")
	if dialogue_box:
		dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
		dialogue_box.dialogue_started.connect(_on_dialogue_started)
		dialogue_box.question_answered_right.connect(_on_question_answered_right)
	
	if textureHead and textureBody:
		$UpperBodySprite.texture = textureHead
		$LowerBodySprite.texture = textureBody


func _parse_dialogue():
	var parsed = JSON.parse_string(dialogue_file)
	if parsed is Dictionary:
		dialogue_dict = parsed
	else:
		push_error("Erro ao converter JSON. Verifique a sintaxe.")

func _load_dialogue(type: String):
	dialogue_lines = dialogue_dict.get(type, [])

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false

func _on_dialogue_started():
	dialogue_active = true

func _on_dialogue_finished():
	dialogue_active = false
	if question_answered and not notificated:
		notificated = true
		notification_box.show_notification()

func _on_question_answered_right(npc_id:String):
	if npc_id == id:
		question_answered = true
		GameState.get_key_part(npc_id)

func turn_to_player(player_dir: String):
	if player_dir == "right":
		$UpperBodySprite.frame_coords = Vector2i(1,2)
		$LowerBodySprite.frame_coords = Vector2i(1,3)
	elif player_dir == "left":
		$UpperBodySprite.frame_coords = Vector2i(1,4)
		$LowerBodySprite.frame_coords = Vector2i(1,5)
	elif player_dir == "down":
		$UpperBodySprite.frame_coords = Vector2i(1,6)
		$LowerBodySprite.frame_coords = Vector2i(1,7)
	elif player_dir == "up":
		$UpperBodySprite.frame_coords = Vector2i(1,0)
		$LowerBodySprite.frame_coords = Vector2i(1,1)


func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact") and not dialogue_active:
		turn_to_player(get_tree().current_scene.get_node("Player").get_last_direction())
		if dialogue_box and not dialogue_box.visible:
			dialogue_active = true
			if !question_answered:
				_load_dialogue("Question_dialogue")
				dialogue_box.show_dialogue(dialogue_lines)
			else :
				_load_dialogue("Default_dialogue")
				dialogue_box.show_dialogue(dialogue_lines)
