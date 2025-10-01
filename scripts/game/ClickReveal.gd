# res://scripts/game/ClickReveal.gd
extends Node2D

@export var click_radius: int = 3
@export var mouse_button: int = MOUSE_BUTTON_LEFT

# auto-find węzłów po nazwie (działa bez ustawiania w Inspectorze)
@onready var _terrain_layer: TileMapLayer = (
	get_tree().get_current_scene().find_child("Terrain", true, false) as TileMapLayer
)
@onready var _terrain_legacy: TileMap = (
	get_tree().get_current_scene().find_child("Terrain", true, false) as TileMap
)
@onready var _fow: Node = (
	get_tree().get_current_scene().find_child("FogOfWar", true, false)
)

func _unhandled_input(event: InputEvent) -> void:
	if _fow == null or (_terrain_layer == null and _terrain_legacy == null):
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == mouse_button:
		var world: Vector2 = get_global_mouse_position()
		var cell: Vector2i = _to_cell(world)
		if not _cell_exists_on_terrain(cell):
			return

		# preferuj szybkie odsłonięcie lokalne, jeśli masz tę metodę
		if _fow.has_method("reveal_single"):
			_fow.reveal_single(cell, click_radius)
			return

		# fallback: przebuduj FOW wokół jednego „źródła”
		var src: Array[Vector2i] = []
		src.append(cell)
		_fow.rebuild_fog(src)

# -------- helpers --------

func _to_cell(world: Vector2) -> Vector2i:
	if _terrain_layer != null:
		var tm := _terrain_layer
		return tm.local_to_map(tm.to_local(world))
	elif _terrain_legacy != null:
		var tm2 := _terrain_legacy
		return tm2.local_to_map(tm2.to_local(world))
	return Vector2i.ZERO

func _cell_exists_on_terrain(cell: Vector2i) -> bool:
	if _terrain_layer != null:
		return _terrain_layer.get_cell_source_id(cell) != -1
	elif _terrain_legacy != null:
		return _terrain_legacy.get_cell_source_id(0, cell) != -1
	return false
