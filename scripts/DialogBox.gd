extends CanvasLayer

@export var char_speed := 0.03 # tempo entre caracteres
var current_text := ""
var displayed_text := ""
var char_index := 0
var lines : Array = []
var is_typing := false
var can_continue := false
var is_dialogue_active:= false
signal dialogue_started
signal dialogue_finished

@onready var speaker_label = $Panel/VBoxContainer/SpeakerLabel
@onready var text_label = $Panel/VBoxContainer/TextLabel
@onready var char_timer = $CharTimer

func _ready():
	hide()
	char_timer.timeout.connect(_on_char_timer_timeout)

func show_dialogue(dialogue_data : Array):
	lines = dialogue_data.duplicate()
	show()
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
	speaker_label.text = line.get("speaker", "")
	current_text = line.get("text", "")
	displayed_text = ""
	char_index = 0
	text_label.clear()
	text_label.append_text(current_text)
	is_typing = true
	char_timer.start(char_speed)

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
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			# Mostra tudo de uma vez
			char_timer.stop()
			text_label.clear()
			text_label.append_text(current_text)
			is_typing = false
			can_continue = true
		elif can_continue:
			can_continue = false
			_next_line()
