# res://scripts/ui/MainMenu.gd
extends Control

# Ścieżki do scen
const GAME_SCENE := "res://scenes/game/game.tscn"
const OPTIONS_SCENE := "res://scenes/main/Options.tscn"

func _ready() -> void:
	# Podpinamy przyciski po nazwie z VBoxContainer
	$VBoxContainer/Start.pressed.connect(_on_start_pressed)
	$VBoxContainer/Opcje.pressed.connect(_on_options_pressed)
	$VBoxContainer/Wyjscie.pressed.connect(_on_exit_pressed)

# -------------------------------
# Obsługa przycisków
# -------------------------------

func _on_start_pressed() -> void:
	if ResourceLoader.exists(GAME_SCENE):
		get_tree().change_scene_to_file(GAME_SCENE)
	else:
		push_warning("Scena gry nie znaleziona: %s" % GAME_SCENE)

func _on_options_pressed() -> void:
	if ResourceLoader.exists(OPTIONS_SCENE):
		get_tree().change_scene_to_file("res://scenes/main/Options.tscn")
	else:
		push_warning("Scena opcji jeszcze nie istnieje: %s" % OPTIONS_SCENE)

func _on_exit_pressed() -> void:
	get_tree().quit()
