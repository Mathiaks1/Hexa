# res://scripts/game/FogOfWar.gd
extends Node
class_name FogOfWar

@export var tm_terrain_path: NodePath
@export var tm_fog_path: NodePath

# Źródło tilesetu i indeksy (dostosuj do swojego TileSetu)
@export var fog_source_id: int = 0      # TileSet source id dla TileMapFog
@export var tile_black_id: int = 0      # atlas_coords.x kafelka "pełna mgła"
@export var tile_dim_id: int = 1        # atlas_coords.x kafelka "pół mgły"

@export var vision_radius: int = 3

var _tm_terrain: TileMap
var _tm_fog: TileMap
var _discovered: Dictionary = {}        # Set: Vector2i -> true

func _ready() -> void:
	_tm_terrain = get_node(tm_terrain_path) as TileMap
	_tm_fog = get_node(tm_fog_path) as TileMap
	_fill_black()

func _fill_black() -> void:
	var r: Rect2i = _tm_terrain.get_used_rect()
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			var c: Vector2i = Vector2i(x, y)
			_tm_fog.set_cell(0, c, fog_source_id, Vector2i(tile_black_id, 0)) # warstwa 0

func rebuild_fog(units_cells: Array[Vector2i]) -> void:
	# 1) Zbierz widoczne komórki
	var visible: Dictionary = {}  # Set<Vector2i>
	for cell in units_cells:
		_bfs_mark_visible(cell, vision_radius, visible)

	# 2) Zapisz „odkryte”
	for c in visible.keys():
		_discovered[c] = true

	# 3) Narysuj mgłę
	var r: Rect2i = _tm_terrain.get_used_rect()
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			var c: Vector2i = Vector2i(x, y)
			if visible.has(c):
				_tm_fog.erase_cell(0, c)  # brak mgły
			elif _discovered.has(c):
				_tm_fog.set_cell(0, c, fog_source_id, Vector2i(tile_dim_id, 0))
			else:
				_tm_fog.set_cell(0, c, fog_source_id, Vector2i(tile_black_id, 0))

func _bfs_mark_visible(start: Vector2i, radius: int, visible: Dictionary) -> void:
	var q: Array[Vector2i] = []
	var dist: Dictionary = {} # Vector2i -> int
	q.append(start)
	dist[start] = 0
	visible[start] = true

	while q.size() > 0:
		var cur: Vector2i = q.pop_front()
		var d: int = int(dist[cur])
		if d >= radius:
			continue

		var neighs: PackedVector2Array = _tm_terrain.get_surrounding_cells(cur)
		for n in neighs:
			var nvi := Vector2i(int(n.x), int(n.y))
			if not dist.has(nvi):
				# (tu możesz dodać is_blocker(nvi) i przerwać promień)
				dist[nvi] = d + 1
				visible[nvi] = true
				q.append(nvi)
