# res://scripts/game/Highlights.gd
extends TileMapLayer
class_name Highlights

@export_node_path var terrain_path: NodePath
@export var source_id: int = 0
@export var use_atlas: bool = true
@export var atlas_coords: Vector2i = Vector2i.ZERO

@export var move_cost_key: StringName = &"move_cost"
@export var blocked_key: StringName = &"blocked"

var _tm: TileMapLayer

func _ready() -> void:
	_tm = get_node(terrain_path) as TileMapLayer

func clear_highlights() -> void:
	clear()

func show_reachable(start_cell: Vector2i, move_points: int) -> void:
	clear()
	if move_points <= 0: return

	var frontier: Array[Vector2i] = [start_cell]
	var cost_so_far: Dictionary = { start_cell: 0 }

	while frontier.size() > 0:
		var current: Vector2i = frontier.pop_front()
		var neighs = _get_neighbors(current)
		for nc in neighs:
			if _is_blocked(nc):
				continue
			var new_cost: int = int(cost_so_far[current]) + _cell_cost(nc)
			if new_cost <= move_points and (not cost_so_far.has(nc) or new_cost < int(cost_so_far[nc])):
				cost_so_far[nc] = new_cost
				frontier.append(nc)

	for c in cost_so_far.keys():
		var cell: Vector2i = c
		if cell == start_cell: continue
		if use_atlas: set_cell(cell, source_id, atlas_coords, 0)
		else: set_cell(cell, source_id)

func _cell_cost(cell: Vector2i) -> int:
	var td: TileData = _tm.get_cell_tile_data(cell)
	if td and td.get_custom_data(move_cost_key) != null:
		return int(td.get_custom_data(move_cost_key))
	return 1

func _is_blocked(cell: Vector2i) -> bool:
	var td: TileData = _tm.get_cell_tile_data(cell)
	if td and td.get_custom_data(blocked_key) != null:
		return bool(td.get_custom_data(blocked_key))
	return false

func _get_neighbors(c: Vector2i) -> Array[Vector2i]:
	# Jeśli Twoja wersja ma metodę helpera:
	if _tm.has_method("get_surrounding_cells"):
		var res: Array[Vector2i] = []
		for v in _tm.get_surrounding_cells(c):
			res.append(Vector2i(int(v.x), int(v.y)))
		return res
	# Fallback (dla pointy-top) – jeśli kiedyś by brakło metody:
	var offsets: Array[Vector2i] = [
		Vector2i( 1, 0), Vector2i(-1, 0),
		Vector2i( 0, 1), Vector2i( 0,-1),
		Vector2i( 1,-1), Vector2i(-1, 1)
	]
	var out: Array[Vector2i] = []
	for o in offsets: out.append(c + o)
	return out
