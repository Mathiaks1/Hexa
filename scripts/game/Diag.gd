extends Node2D

@onready var terrain: TileMapLayer = get_tree().get_current_scene().find_child("Terrain", true, false) as TileMapLayer
@onready var fog: TileMapLayer     = get_tree().get_current_scene().find_child("Fog", true, false) as TileMapLayer
@onready var cursor: TileMapLayer  = get_tree().get_current_scene().find_child("Cursor", true, false) as TileMapLayer
@onready var fow: Node             = get_tree().get_current_scene().find_child("FogOfWar", true, false)

func _ready() -> void:
	print("--- DIAG START ---")
	print_tree_pretty()

	if terrain == null: push_error("DIAG: nie znaleziono TileMapLayer 'Terrain'")
	if fog == null:     push_error("DIAG: nie znaleziono TileMapLayer 'Fog'")
	if cursor == null:  push_error("DIAG: nie znaleziono TileMapLayer 'Cursor'")
	if fow == null:     push_error("DIAG: nie znaleziono noda 'FogOfWar' (ze skryptem FogOfWarSimple.gd)")

	if terrain:
		var r: Rect2i = terrain.get_used_rect()
		print("Terrain.used_rect pos=", r.position, " size=", r.size)
		if r.size == Vector2i.ZERO:
			push_error("DIAG: Terrain nie ma namalowanych kafli!")
		else:
			# spróbuj zamienić środek recta na lokal/world i z powrotem
			var mid: Vector2i = r.position + r.size / 2
			var world: Vector2 = terrain.to_global( terrain.map_to_local(mid) )
			var back_cell: Vector2i = terrain.local_to_map( terrain.to_local(world) )
			print("Roundtrip cell=", mid, " -> world ", world, " -> cell ", back_cell)

	if fog:
		print("Fog TileSet ok? ", fog.tile_set != null, "  source_at_cell(0,0)=", fog.get_cell_source_id(Vector2i(0,0)))
		print("Fog z_index=", fog.z_index)
	if cursor:
		print("Cursor TileSet ok? ", cursor.tile_set != null, "  z_index=", cursor.z_index)

	print("--- DIAG END ---")
	# Na start: wypełnij mgłę (jeśli FOW ma taką metodę) – od razu zobaczysz czy Fog działa:
	if fow and fow.has_method("fill_all_with_dim"):
		fow.fill_all_with_dim()

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		if terrain == null: return
		var world := get_global_mouse_position()
		var cell: Vector2i = terrain.local_to_map(terrain.to_local(world))
		var src_id := terrain.get_cell_source_id(cell)
		print("[CLICK] cell=", cell, " terrain_src_id=", src_id)
		if src_id == -1:
			print("CLICK poza terenem (według Terrain).")
			return

		# 1) pokaż kursorem kafel w tej komórce – żeby sprawdzić Tileset kursora
		if cursor:
			cursor.clear()
			# UŻYJ Single Tile – set_cell(cell, source_id)
			cursor.set_cell(cell, 0)  # <- jeśli masz Single Tile source_id=0; popraw tu ID gdy inne

		# 2) odsłoń mgłę lokalnie – żeby sprawdzić FOW
		if fow:
			if fow.has_method("reveal_single"):
				fow.reveal_single(cell, 3)
			elif fow.has_method("rebuild_fog"):
				var arr: Array[Vector2i] = []
				arr.append(cell)
				fow.rebuild_fog(arr)
