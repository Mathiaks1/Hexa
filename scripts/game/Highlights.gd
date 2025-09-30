extends TileMapLayer
class_name HexHighlights

@export_node_path var terrain_path: NodePath        # wskaż TileMapLayer z terenem (np. Terrain)
@export var source_id: int = 0
@export var use_atlas: bool = true
@export var atlas_coords: Vector2i = Vector2i.ZERO
@export var move_cost_key: StringName = &"move_cost"
@export var blocked_key: StringName = &"blocked"

var _tm: TileMapLayer

func _ready() -> void:
	if not _resolve_terrain():
		return

func _resolve_terrain() -> bool:
	# 1) Spróbuj z pola w Inspectorze
	_tm = get_node_or_null(terrain_path) as TileMapLayer
	# 2) Spróbuj ścieżki względnej "../Terrain"
	if _tm == null:
		var n := get_node_or_null("../Terrain")
		if n is TileMapLayer: _tm = n
	# 3) Szukaj po nazwie w całej scenie
	if _tm == null:
		_tm = find_child("Terrain", true, false) as TileMapLayer
	# 4) Błąd + drzewo
	if _tm == null:
		push_error("HexHighlights: wskaż 'terrain_path' w Inspectorze albo nazwij node terenu 'Terrain' (Unique Name).")
		print_tree_pretty()
		return false
	return true

func clear_highlights() -> void:
	clear()

func show_reachable(start_cell: Vector2i, move_points: int) -> void:
	if not _resolve_terrain(): return
	clear()
	if move_points <= 0: return

	var frontier: Array[Vector2i] = [start_cell]
	var cost: Dictionary = { start_cell: 0 }

	while frontier.size() > 0:
		var cur: Vector2i = frontier.pop_front()
		for v in _tm.get_surrounding_cells(cur):
			var nc := Vector2i(int(v.x), int(v.y))
			if _is_blocked(nc): continue
			var new_cost := int(cost[cur]) + _cell_cost(nc)
			if new_cost <= move_points and (not cost.has(nc) or new_cost < int(cost[nc])):
				cost[nc] = new_cost
				frontier.append(nc)

	for c in cost.keys():
		var cell: Vector2i = c
		if cell == start_cell: continue
		if use_atlas: set_cell(cell, source_id, atlas_coords, 0)
		else: set_cell(cell, source_id)

func _cell_cost(cell: Vector2i) -> int:
	var td := _tm.get_cell_tile_data(cell)
	if td and td.get_custom_data(move_cost_key) != null:
		return int(td.get_custom_data(move_cost_key))
	return 1

func _is_blocked(cell: Vector2i) -> bool:
	var td := _tm.get_cell_tile_data(cell)
	if td and td.get_custom_data(blocked_key) != null:
		return bool(td.get_custom_data(blocked_key))
	return false
