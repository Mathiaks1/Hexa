extends TileMapLayer
# upewnij się: Tileset → SingleTile; jego source_id == 0 (albo popraw poniżej)

func show_at(cell: Vector2i) -> void:
	clear()
	set_cell(cell, 0) # jeśli twój SingleTile ma inne ID niż 0 → popraw tutaj
