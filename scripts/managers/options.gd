# res://scripts/ui/options.gd
extends Control

const MAIN_MENU_SCENE := "res://scenes/main/main_menu.tscn"

# W Inspectorze wskaż tu swoje przyciski (przeciągnij z drzewa sceny)
@export var path_btn_fullscreen: NodePath
@export var path_btn_back: NodePath

@onready var btn_fullscreen: Button = get_node_or_null(path_btn_fullscreen)
@onready var btn_back: Button = get_node_or_null(path_btn_back)

func _ready() -> void:
	if btn_fullscreen:
		btn_fullscreen.pressed.connect(_on_fullscreen_pressed)
	else:
		push_error("Ustaw 'path_btn_fullscreen' w Inspectorze (np. VBoxContainer/Pełny ekran)."); print_tree_pretty()

	if btn_back:
		btn_back.pressed.connect(_on_back_pressed)
	else:
		push_error("Ustaw 'path_btn_back' w Inspectorze (np. VBoxContainer/Powrót)."); print_tree_pretty()

func _on_fullscreen_pressed() -> void:
	var mode := DisplayServer.window_get_mode()
	var new_mode := DisplayServer.WINDOW_MODE_WINDOWED if mode == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(new_mode)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
