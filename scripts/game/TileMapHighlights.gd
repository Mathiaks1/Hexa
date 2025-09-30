# res://scripts/game/Highlights.gd
extends TileMap
class_name Highlights

@export_node_path var terrain_path: NodePath            # wskazujesz TileMapTerrain
@export var source_id: int = 0                          # source z kaflem półprzezroczystym
@export var atlas_coords: Vector2i = Vector2i.ZERO      # pozycja kafla w atlasie (jeśli AtlasSource)
@export var use_atlas: bool = true                      # false jeśli SingleTileSource bez atlasu

# nazwy custom data w TileSet (opcjonalnie)
@export var move_cost_key: StringName = &"move_cost"    # koszt ruchu pola; domyślnie 1
@export var blocked_key: StringName = &"blocked"        # bool: czy pole nieprzechodnie

var _tm: TileMap

func _ready() -> void:
	_tm = get_node(terrain_path) as TileMap

func clear_highlights() -> void:
	clear()

func show_reachable(start_cell: Vector2i, move_points: int) -> void:
	clear()
	if move_points <= 0:
		return

	# Dijkstra (BFS z kosztami)
	var frontier: Array[Vector2i] = [start_cell]
	var cost_so_far: = { start_cell: 0 } as Dictionary

	while frontier.size() > 0:
		var current: Vector2i = frontier.pop_front()
		# sąsiedzi heksa
		var neighs: PackedVector2Array = _tm.get_surrounding_cells(current)
		for n in neighs:
			var nc: Vector2i = Vector2i(int(n.x), int(n.y))
			if _is_blocked(nc):
				continue
			var new_cost: int = int(cost_so_far[current]) + _cell_cost(nc)
			if new_cost <= move_points and (not cost_so_far.has(nc) or new_cost < int(cost_so_far[nc])):
				cost_so_far[nc] = new_cost
				frontier.append(nc)

	# narysuj highlighty (bez pola startowego – jeśli chcesz, usuń if)
	for c in cost_so_far.keys():
		var cell: Vector2i = c
		if cell == start_cell:
			continue
		_set_highlight(cell)

func _set_highlight(cell: Vector2i) -> void:
	if use_atlas:
		set_cell(0, cell, source_id, atlas_coords)
	else:
		set_cell(0, cell, source_id)

func _cell_cost(cell: Vector2i) -> int:
	# domyślnie 1; jeśli w TileSet masz Custom Data "move_cost", to użyje jego wartości
	var td: TileData = _tm.get_cell_tile_data(0, cell)
	if td and td.get_custom_data(move_cost_key) != null:
		return int(td.get_custom_data(move_cost_key))
	return 1

func _is_blocked(cell: Vector2i) -> bool:
	# Jeśli masz Custom Data "blocked" = true (np. woda/góry), potraktuj jako nieprzechodnie
	var td: TileData = _tm.get_cell_tile_data(0, cell)
	if td and td.get_custom_data(blocked_key) != null:
		return bool(td.get_custom_data(blocked_key))
	return false
