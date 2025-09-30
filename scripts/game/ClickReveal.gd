extends Node2D

@export_node_path var terrain_path: NodePath
@export_node_path var fow_path: NodePath
@export var click_radius: int = 3
@export var mouse_button: int = MOUSE_BUTTON_LEFT

var _terrain: Node        # TileMapLayer lub TileMap
var _fow: Node

func _ready() -> void:
	_resolve_nodes()
	if _terrain == null or _fow == null:
		push_error("ClickReveal: ustaw 'terrain_path' (../Terrain) i 'fow_path' (../FogOfWar).")
		print_tree_pretty()

func _unhandled_input(event: InputEvent) -> void:
	if _terrain == null or _fow == null:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == mouse_button:
		var world: Vector2 = get_global_mouse_position()
		var cell: Vector2i = _to_cell(world)
		if not _cell_exists_on_terrain(cell):
			return

		# 1) preferuj lokalne odsłonięcie jeśli masz funkcję reveal_single
		if _fow.has_method("reveal_single"):
			_fow.call("reveal_single", cell, click_radius)
			return

		# 2) wywołaj rebuild_fog z TABLICĄ TYPOWANĄ i najlepiej bezpośrednio na klasie
		var arr: Array[Vector2i] = []
		arr.append(cell)

		if _fow is FogOfWar:
			(_fow as FogOfWar).rebuild_fog(arr)
		else:
			# awaryjnie spróbuj przez Callable (z typowaną tablicą)
			var cb := Callable(_fow, "rebuild_fog")
			cb.call(arr)

# ---------------- helpers ----------------

func _resolve_nodes() -> void:
	_terrain = get_node_or_null(terrain_path)
	_fow     = get_node_or_null(fow_path)

	# jeśli w polach wpisano nazwy rodzeństwa, dodaj "../"
	if _terrain == null and String(terrain_path) != "":
		var p := String(terrain_path)
		if not p.begins_with("../"): p = "../" + p
		_terrain = get_parent().get_node_or_null(p)

	if _fow == null and String(fow_path) != "":
		var q := String(fow_path)
		if not q.begins_with("../"): q = "../" + q
		_fow = get_parent().get_node_or_null(q)

	# fallback po nazwie u rodzica
	if _terrain == null: _terrain = get_parent().find_child("Terrain", false, false)
	if _fow == null:     _fow     = get_parent().find_child("FogOfWar", false, false)

func _to_cell(world: Vector2) -> Vector2i:
	if _terrain is TileMapLayer:
		var tm := _terrain as TileMapLayer
		return tm.local_to_map(tm.to_local(world))
	elif _terrain is TileMap:
		var tm2 := _terrain as TileMap
		return tm2.local_to_map(tm2.to_local(world))
	return Vector2i.ZERO

func _cell_exists_on_terrain(cell: Vector2i) -> bool:
	if _terrain is TileMapLayer:
		return (_terrain as TileMapLayer).get_cell_source_id(cell) != -1
	elif _terrain is TileMap:
		return (_terrain as TileMap).get_cell_source_id(0, cell) != -1
	return false
