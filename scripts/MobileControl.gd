extends CanvasLayer

@onready var joystick_base = $UIRoot/JoystickBase
@onready var joystick_knob = $UIRoot/JoystickBase/JoystickKnob
@onready var interact_button = $UIRoot/ActionButton
@onready var enter_button = $UIRoot/EnterButton

var joystick_vector := Vector2.ZERO
var dragging := false
var drag_index := -1
var joystick_radius: float = 100
var enter_button_pressed:=false
var interact_button_pressed:=false

var joystick_touch_index := -1

func _ready():
	interact_button.pressed.connect(_on_interact_pressed)
	enter_button.pressed.connect(_on_enter_pressed)
	joystick_knob.position = (joystick_base.size - joystick_knob.size) * 0.5
	joystick_radius = joystick_base.size.x * 0.4

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.pressed and _is_touch_inside_base(event.position):
			dragging = true
			joystick_touch_index = event.index  # Guarda o índice do dedo
		elif  not event.pressed and event.index == joystick_touch_index:
			_reset_joystick()
	if event is InputEventScreenDrag and event.index == joystick_touch_index and dragging:
		_update_joystick_position(event.position)

func _is_touch_inside_base(touch_position: Vector2) -> bool:
	# Cria um retângulo representando a área da base
	var base_rect := Rect2(joystick_base.global_position, joystick_base.size)
	# Verifica se o ponto está dentro do retângulo
	return base_rect.has_point(touch_position)

# Atualiza a posição do stick com base no toque
func _update_joystick_position(touch_position: Vector2):
	# Calcula o centro global da base
	var base_center = joystick_base.global_position + joystick_knob.size * 0.5
	
	# Vetor do centro da base até a posição do toque
	var direction = touch_position - base_center
	
	# Limita o movimento ao raio máximo (círculo virtual)
	if direction.length() > joystick_radius:
		direction = direction.normalized() * joystick_radius
	
	# Atualiza a posição visual do stick (posição relativa à base)
	joystick_knob.position = (joystick_base.size - joystick_knob.size) * 0.5 + direction
	
	# Calcula a saída normalizada (-1 a 1 em ambos os eixos)
	joystick_vector = direction / joystick_radius

# Reseta o joystick para o estado inicial
func _reset_joystick():
	dragging = false
	joystick_touch_index = -1
	joystick_knob.position = (joystick_base.size - joystick_knob.size) * 0.5
	joystick_vector = Vector2.ZERO

# Retorna o vetor de direção para uso externo
func get_direction() -> Vector2:
	return joystick_vector

func get_direction_name(vector: Vector2) -> String:
	if vector == Vector2.ZERO:
		return "idle"
	if abs(vector.x) > abs(vector.y):
		return "move-right" if vector.x > 0 else "move-left"
	else:
		return "move-down" if vector.y > 0 else "move-up"

func _on_interact_pressed():
	interact_button_pressed = true
	await get_tree().create_timer(1).timeout
	interact_button_pressed = false
	

func _on_enter_pressed():
	enter_button_pressed = true
	await get_tree().create_timer(1).timeout
	enter_button_pressed = false

func action_pressed() -> bool:
	return interact_button and interact_button_pressed

func enter_pressed() -> bool:
	return enter_button and enter_button_pressed

func is_mobile_browser() -> bool:
	if OS.get_name() != "Web":
		return false
	return JavaScriptBridge.eval("""
		(function() {
			return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
		})()
	""")
