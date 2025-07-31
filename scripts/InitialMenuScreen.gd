extends Control

func _ready() -> void:
	AudioManager.play_bgm("res://assets/audio/music/Kevin MacLeod - 8bit Dungeon Level ♫ NO COPYRIGHT 8-bit Music.mp3")
	$Button.pressed.connect(_on_button_pressed)
	

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/World.tscn")
