extends StaticBody2D

var player_in_range := false
var mobile_controls

func _ready() -> void:
	mobile_controls = get_tree().current_scene.get_node("MobileControl")
	$InteractiveArea.body_entered.connect(_on_body_entered)
	$InteractiveArea.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false

func _process(_delta):
	if player_in_range and (Input.is_action_just_pressed("interact") or mobile_controls.action_pressed()):
		AudioManager.play_sfx("res://assets/audio/SFX/sound1.wav")
		get_tree().change_scene_to_file("res://scenes/LinksScreen.tscn")
