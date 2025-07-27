extends CharacterBody2D

@export var dialogue_file : Resource
@export var npc_name: String
@export var id: String
@export var textureHead: Texture2D
@export var textureBody: Texture2D

var dialogue_lines: Array

var player_in_range := false
var dialogue_active = false
var question_answered = false
@onready var dialogue_box = get_tree().current_scene.get_node("DialogBox")

func _ready():
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)
	_load_dialogue("Default_dialogue")
	
	var dialogue_box = get_tree().current_scene.get_node("DialogBox")
	if dialogue_box:
		dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
		dialogue_box.question_answered_right.connect(_on_question_answered_right)
	
	if textureHead and textureBody:
		$UpperBodySprite.texture = textureHead
		$LowerBodySprite.texture = textureBody

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

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false

func _on_dialogue_finished():
	dialogue_active = false

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
	if player_in_range and Input.is_action_just_pressed("interact"):
		turn_to_player(get_tree().current_scene.get_node("Player").get_last_direction())
		if dialogue_box and not dialogue_active and not dialogue_box.visible:
			if !question_answered:
				_load_dialogue("Question_dialogue")
				dialogue_box.show_dialogue(dialogue_lines)
			else :
				_load_dialogue("Default_dialogue")
				dialogue_box.show_dialogue(dialogue_lines)
			dialogue_active = true
