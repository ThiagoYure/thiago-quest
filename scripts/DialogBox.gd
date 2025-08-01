extends CanvasLayer

@export var char_speed := 0.03 # tempo entre caracteres
var current_text := ""
var displayed_text := ""
var char_index := 0
var lines : Array = []
var is_typing := false
var can_continue := false
var is_dialogue_active:= false
var current_choice_index:=0
var buttons: Array = []
var choices_list: Array = []
var question_line:={}
var mobile_controls
signal dialogue_started
signal dialogue_finished
signal question_answered_right(npc_id: String)

@onready var speaker_label = $Panel/VBoxContainer/SpeakerLabel
@onready var text_label = $Panel/VBoxContainer/TextLabel
@onready var char_timer = $CharTimer
@onready var choice_container = $Panel/VBoxContainer/ChoiceContainer

func _ready():
	mobile_controls = get_tree().current_scene.get_node("MobileControl")
	hide()
	char_timer.timeout.connect(_on_char_timer_timeout)

func show_dialogue(dialogue_data : Array):
	buttons.clear()
	choices_list.clear()
	question_line = {}
	current_choice_index = 0
	lines = dialogue_data.duplicate()
	emit_signal("dialogue_started")
	AudioManager.play_sfx("res://assets/audio/SFX/sound6.wav")
	show()
	for item in choice_container.get_children():
		item.queue_free()
	emit_signal("dialogue_started")
	is_dialogue_active = true
	_next_line()

func _next_line():
	if lines.is_empty():
		hide()
		is_dialogue_active = false
		emit_signal("dialogue_finished") # <-- avisa que terminou
		return
	var line = lines.pop_front()
	
	if line.get("type") == "text":
		speaker_label.text = line.get("speaker_name", "")
		current_text = line.get("text", "")
		displayed_text = ""
		char_index = 0
		text_label.clear()
		is_typing = true
		char_timer.start(char_speed)
	elif line.get("type") == "question":
		speaker_label.text = line.get("speaker_name", "")
		current_text = line.get("question", "")
		displayed_text = ""
		char_index = 0
		is_typing = true
		char_timer.start(char_speed)
		var choices : Array = line.get("options")
		choice_container.visible = true
		for choice in choices:
			var button = Button.new()
			button.text = choice
			button.pressed.connect(_on_choice_selected.bind(choice, line))
			choice_container.add_child(button)
			buttons.append(button)
			choices_list.append(choice)
			question_line = line
			is_typing = false
		att_choices()

func _on_char_timer_timeout():
	if char_index < current_text.length():
		displayed_text += current_text[char_index]
		char_index += 1
		text_label.clear()
		text_label.append_text(displayed_text)
		char_timer.start(char_speed)
	else:
		is_typing = false
		can_continue = true

func _unhandled_input(event):
	var dir_name = mobile_controls.get_direction_name(mobile_controls.get_direction())
	if (Input.is_action_just_pressed("ui_accept") or mobile_controls.enter_pressed()) and buttons.size() == 0:
		if is_typing:
			char_timer.stop()
			text_label.clear()
			text_label.append_text(current_text)
			is_typing = false
			can_continue = true
		elif can_continue:
			can_continue = false
			_next_line()
	elif (Input.is_action_just_pressed("ui_accept") or mobile_controls.enter_pressed()) and buttons.size() > 0:
		_on_choice_selected(choices_list[current_choice_index], question_line)
		buttons.clear()
		choices_list.clear()
		question_line={}
	elif buttons.size() > 0 and is_dialogue_active and (Input.is_action_just_pressed("move-down") or Input.is_action_just_pressed("move-up") or dir_name == "move-up" or dir_name == "move-down"):
		if(Input.is_action_just_pressed("move-down") or dir_name == "move-down"):
			if current_choice_index == (buttons.size() - 1):
				current_choice_index = 0
			else: current_choice_index += 1
			att_choices()
		elif(Input.is_action_just_pressed("move-up") or dir_name == "move-up"):
			if current_choice_index == 0:
				current_choice_index = (buttons.size() - 1)
			else: current_choice_index -= 1
			att_choices()

func att_choices():
	for i in buttons.size():
		if i == current_choice_index :
			buttons[i].modulate = Color.YELLOW
		else: buttons[i].modulate = Color.WHITE

func _on_choice_selected(choice, line):
	choice_container.visible = false
	var correct_answer = line.get("correct_answer")
	if choice == correct_answer:
		lines.push_front(line.get("if_right"))
		_next_line()
		emit_signal("question_answered_right", line.get("npc_id"))
	else : 
		lines.push_front(line.get("if_wrong"))
		_next_line()
