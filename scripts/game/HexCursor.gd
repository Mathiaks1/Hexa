# res://scripts/game/HexCursor.gd
extends TileMapLayer
class_name HexCursor

@export_node_path var terrain_path: NodePath        # wskaż TileMapTerrain (TileMapLayer)
@export var source_id: int = 0                      # ID source w TileSet kursora
@export var use_atlas: bool = true                  # true: AtlasSource, false: SingleTile
@export var atlas_coords: Vector2i = Vector2i.ZERO  # (0,0) jeśli jedyny kafel

var _terrain: TileMapLayer

func _ready() -> void:
	z_index = 1000
	_terrain = get_node_or_null(terrain_path) as TileMapLayer
	if _terrain == null:
		push_error("HexCursor: ustaw 'terrain_path' na TileMapTerrain.")
	clear()

func _process(_delta: float) -> void:
	clear()
	if _terrain == null:
		return

	var world: Vector2 = get_global_mouse_position()
	var cell: Vector2i = _terrain.local_to_map(_terrain.to_local(world))

	# Rysuj tylko, gdy pod spodem istnieje kafel terenu
	if _terrain.get_cell_source_id(cell) == -1:
		return

	if use_atlas:
		set_cell(cell, source_id, atlas_coords, 0)
	else:
		set_cell(cell, source_id)
