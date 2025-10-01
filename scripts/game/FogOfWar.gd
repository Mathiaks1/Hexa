extends Node
class_name FogOfWarSimple

@export_node_path var terrain_path: NodePath
@export_node_path var fog_path: NodePath
@export var use_atlas: bool = false
@export var fog_source_id: int = 0
@export var fog_atlas_coords: Vector2i = Vector2i.ZERO
@export var vision_radius: int = 3

var _t: TileMapLayer
var _f: TileMapLayer

func _ready() -> void:
	_t = get_node_or_null(terrain_path) as TileMapLayer
	_f = get_node_or_null(fog_path) as TileMapLayer
	if _t == null: _t = get_tree().get_current_scene().find_child("Terrain", true, false) as TileMapLayer
	if _f == null: _f = get_tree().get_current_scene().find_child("Fog", true, false) as TileMapLayer
	if _t == null or _f == null:
		push_error("FOW: brak Terrain/Fog.")
		print_tree_pretty()
		return
	fill_all_with_dim()

func fill_all_with_dim() -> void:
	var r: Rect2i = _t.get_used_rect()
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			_set_fog_cell(Vector2i(x, y))   # <-- tu zmienione

func reveal_single(center: Vector2i, radius: int = 3) -> void:
	if _t == null or _f == null: return
	var q: Array[Vector2i] = []
	q.append(center)
	var dist: Dictionary = {}
	dist[center] = 0

	while q.size() > 0:
		var cur: Vector2i = q[0]
		q.remove_at(0)

		_f.erase_cell(cur)

		var d: int = int(dist.get(cur, 0))
		if d >= radius: continue
		for v in _t.get_surrounding_cells(cur):
			var nc: Vector2i = Vector2i(int(v.x), int(v.y))
			if not dist.has(nc):
				dist[nc] = d + 1
				q.append(nc)

func _set_fog_cell(c: Vector2i) -> void:   # <-- nowa nazwa, bez kolizji z Node._set()
	if use_atlas:
		_f.set_cell(c, fog_source_id, fog_atlas_coords, 0)
	else:
		_f.set_cell(c, fog_source_id)
