extends CharacterBody2D

@export var speed: float = 200.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var last_direction: String = "down"
var can_move := true
var is_walking := false
var mobile_controls

func _ready() -> void:
	mobile_controls = get_tree().current_scene.get_node("MobileControl")
	var dialogue_box = get_tree().current_scene.get_node("DialogBox")
	if dialogue_box:
		dialogue_box.dialogue_started.connect(_on_dialogue_started)
		dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

func _physics_process(delta: float) -> void:
	if not can_move:
		return
	move_player(delta)

func move_player(delta):
	var direction = Vector2.ZERO
	if mobile_controls.is_mobile_browser():
		direction = mobile_controls.get_direction()
	else:
		if Input.is_action_pressed("move-up"):
			direction.y -= 1
		if Input.is_action_pressed("move-down"):
			direction.y += 1
		if Input.is_action_pressed("move-left"):
			direction.x -= 1
		if Input.is_action_pressed("move-right"):
			direction.x += 1
			
	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()

	update_animation(direction)

func update_animation(direction: Vector2):
	if direction != Vector2.ZERO:
		is_walking = true
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				play_animation("walking-right")
				last_direction = "right"
			else:
				play_animation("walking-left")
				last_direction = "left"
		else:
			if direction.y > 0:
				play_animation("walking-down")
				last_direction = "down"
			else:
				play_animation("walking-up")
				last_direction = "up"
	else:
		is_walking = false
		play_animation("idle-" + last_direction)

func play_animation(name: String):
	if animation_player.current_animation != name:
		animation_player.play(name)

func _on_dialogue_started():
	can_move = false
	animation_player.stop()

func _on_dialogue_finished():
	can_move = true
	animation_player.play("idle_" + last_direction)

func get_last_direction():
	return last_direction
