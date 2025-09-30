# res://scripts/game/FogOfWarSimple.gd
extends Node
class_name FogOfWarSimple

@export_node_path var tm_terrain_path: NodePath   # możesz zostawić puste
@export_node_path var tm_fog_path: NodePath       # możesz zostawić puste

@export var fog_source_id: int = 0
@export var use_atlas: bool = true
@export var fog_atlas_coords: Vector2i = Vector2i.ZERO
@export var vision_radius: int = 3

var _tm_terrain: TileMap
var _tm_fog: TileMap

func _ready() -> void:
	if not _resolve_nodes():
		return
	fill_all_with_dim()

func _resolve_nodes() -> bool:
	# 1) jeśli podane w Inspectorze – użyj ich
	if tm_terrain_path != NodePath(""):
		_tm_terrain = get_node_or_null(tm_terrain_path) as TileMap
	if tm_fog_path != NodePath(""):
		_tm_fog = get_node_or_null(tm_fog_path) as TileMap

	# 2) fallback: spróbuj znajdować po NAZWIE
	if _tm_terrain == null:
		_tm_terrain = find_child("TileMapLayer", true, false) as TileMap
	if _tm_fog == null:
		_tm_fog = find_child("TileMapFog", true, false) as TileMap

	# 3) fallback: pierwszy TileMap jako teren, drugi jako mgła
	if _tm_terrain == null or _tm_fog == null:
		var tms: Array = []
		for c in get_children():
			if c is TileMap:
				tms.append(c)
		if tms.size() >= 2:
			if _tm_terrain == null: _tm_terrain = tms[0]
			if _tm_fog == null:     _tm_fog     = tms[1]

	# 4) ostatecznie: błąd i pokaż drzewo
	if _tm_terrain == null:
		push_error("FogOfWarSimple: nie znaleziono TileMap TERENU. Ustaw 'tm_terrain_path' lub nazwij node 'TileMapLayer'.")
		print_tree_pretty()
		return false
	if _tm_fog == null:
		push_error("FogOfWarSimple: nie znaleziono TileMap MGŁY. Ustaw 'tm_fog_path' lub nazwij node 'TileMapFog'.")
		print_tree_pretty()
		return false
	return true

func fill_all_with_dim() -> void:
	if _tm_terrain == null or _tm_fog == null:
		if not _resolve_nodes(): return
	var r: Rect2i = _tm_terrain.get_used_rect()
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			_set_fog(Vector2i(x, y))

func rebuild_fog(units_cells: Array[Vector2i]) -> void:
	if _tm_terrain == null or _tm_fog == null:
		if not _resolve_nodes(): return

	var visible: Dictionary = {}
	for cell in units_cells:
		_bfs_mark_visible(cell, vision_radius, visible)

	var r: Rect2i = _tm_terrain.get_used_rect()
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			var c := Vector2i(x, y)
			if visible.has(c):
				_tm_fog.erase_cell(0, c)
			else:
				_set_fog(c)

func _set_fog(c: Vector2i) -> void:
	if use_atlas:
		_tm_fog.set_cell(0, c, fog_source_id, fog_atlas_coords)
	else:
		_tm_fog.set_cell(0, c, fog_source_id)

func _bfs_mark_visible(start: Vector2i, radius: int, visible: Dictionary) -> void:
	var q: Array[Vector2i] = [start]
	var dist: Dictionary = { start: 0 }
	visible[start] = true

	while q.size() > 0:
		var cur: Vector2i = q.pop_front()
		var d := int(dist[cur])
		if d >= radius:
			continue
		var neighs := _tm_terrain.get_surrounding_cells(cur)
		for n in neighs:
			var nvi := Vector2i(int(n.x), int(n.y))
			if not dist.has(nvi):
				dist[nvi] = d + 1
				visible[nvi] = true
				q.append(nvi)
