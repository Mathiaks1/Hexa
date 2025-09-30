# res://scripts/game/HexCursor.gd
extends TileMapLayer
class_name HexCursor

@export_node_path var terrain_path: NodePath        # wskaż TileMapLayer z terenem
@export var source_id: int = 0
@export var use_atlas: bool = true
@export var atlas_coords: Vector2i = Vector2i.ZERO

var _terrain: TileMapLayer

func _ready() -> void:
	z_index = 1000
	if not _resolve_terrain():
		return
	clear()

func _process(_delta: float) -> void:
	if _terrain == null: return
	clear()

	var world: Vector2 = get_global_mouse_position()
	var cell: Vector2i = _terrain.local_to_map(_terrain.to_local(world))

	# rysuj tylko, gdy pod spodem jest kafel terenu
	if _terrain.get_cell_source_id(cell) == -1:
		return

	if use_atlas:
		set_cell(cell, source_id, atlas_coords, 0)
	else:
		set_cell(cell, source_id)

func _resolve_terrain() -> bool:
	# 1) ścieżka z Inspectora
	_terrain = get_node_or_null(terrain_path) as TileMapLayer
	# 2) sąsiad o nazwie "Terrain"
	if _terrain == null:
		var n := get_node_or_null("../Terrain")
		if n is TileMapLayer:
			_terrain = n
	# 3) szukaj po nazwie w całej scenie
	if _terrain == null:
		_terrain = find_child("Terrain", true, false) as TileMapLayer

	if _terrain == null:
		push_error("HexCursor: wskaż 'terrain_path' w Inspectorze albo nazwij warstwę terenu 'Terrain' (Unique Name).")
		print_tree_pretty()
		return false
	return true
