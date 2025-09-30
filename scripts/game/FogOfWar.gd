# res://scripts/game/FogOfWarSimple.gd
extends Node
class_name FogOfWar

@export_node_path var terrain_path: NodePath   # wskaż TileMapLayer z terenem
@export_node_path var fog_path: NodePath       # wskaż TileMapLayer z mgłą

@export var fog_source_id: int = 0
@export var use_atlas: bool = true
@export var fog_atlas_coords: Vector2i = Vector2i.ZERO
@export var vision_radius: int = 3

var _tm_terrain: TileMapLayer
var _tm_fog: TileMapLayer

func _ready() -> void:
	if not _resolve_nodes():
		return
	fill_all_with_dim()

func _resolve_nodes() -> bool:
	# 1) z Inspector-a
	if terrain_path != NodePath(""):
		_tm_terrain = get_node_or_null(terrain_path) as TileMapLayer
	if fog_path != NodePath(""):
		_tm_fog = get_node_or_null(fog_path) as TileMapLayer

	# 2) sąsiedzi o nazwach ../Terrain i ../Fog
	if _tm_terrain == null:
		var n := get_node_or_null("../Terrain")
		if n is TileMapLayer: _tm_terrain = n
	if _tm_fog == null:
		var n2 := get_node_or_null("../Fog")
		if n2 is TileMapLayer: _tm_fog = n2

	# 3) globalne wyszukiwanie po nazwie
	if _tm_terrain == null:
		_tm_terrain = get_tree().get_current_scene().find_child("Terrain", true, false) as TileMapLayer
	if _tm_fog == null:
		_tm_fog = get_tree().get_current_scene().find_child("Fog", true, false) as TileMapLayer

	if _tm_terrain == null or _tm_fog == null:
		push_error("FogOfWarSimple: wskaż 'terrain_path' i 'fog_path' w Inspectorze albo nazwij warstwy 'Terrain' i 'Fog'.")
		print_tree_pretty()
		return false
	return true

func fill_all_with_dim() -> void:
	var r: Rect2i = _tm_terrain.get_used_rect()
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			_set_fog(Vector2i(x, y))

func rebuild_fog(units_cells: Array[Vector2i]) -> void:
	var visible: Dictionary = {}
	for cell in units_cells:
		_bfs_mark_visible(cell, vision_radius, visible)

	var r: Rect2i = _tm_terrain.get_used_rect()
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			var c := Vector2i(x, y)
			if visible.has(c):
				_tm_fog.erase_cell(c)
			else:
				_set_fog(c)

func _set_fog(c: Vector2i) -> void:
	if use_atlas:
		_tm_fog.set_cell(c, fog_source_id, fog_atlas_coords, 0)
	else:
		_tm_fog.set_cell(c, fog_source_id)

func _bfs_mark_visible(start: Vector2i, radius: int, visible: Dictionary) -> void:
	var q: Array[Vector2i] = [start]
	var dist: Dictionary = { start: 0 }
	visible[start] = true

	while q.size() > 0:
		var cur: Vector2i = q.pop_front()
		var d := int(dist[cur])
		if d >= radius: continue

		for v in _tm_terrain.get_surrounding_cells(cur):
			var nc := Vector2i(int(v.x), int(v.y))
			if not dist.has(nc):
				dist[nc] = d + 1
				visible[nc] = true
				q.append(nc)
