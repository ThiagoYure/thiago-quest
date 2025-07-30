extends Control

func _on_button_pressed() -> void:
	OS.shell_open("https://drive.google.com/file/d/1s_RqfNYfUwo_3DgMEZK6BYpld61AVna1/view?usp=sharing")


func _on_button_2_pressed() -> void:
	OS.shell_open("https://www.linkedin.com/in/thiagoyure/")


func _on_button_3_pressed() -> void:
	OS.shell_open("https://github.com/ThiagoYure")


func _on_button_4_pressed() -> void:
	OS.shell_open("https://www.behance.net/thiagoyureart")


func _on_button_sair_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/InitialMenuScreen.tscn")
