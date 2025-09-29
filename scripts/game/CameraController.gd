# res://scripts/game/CameraController.gd
extends Camera2D

@export var tilemap_path: NodePath
@export var pan_button: int = MOUSE_BUTTON_RIGHT
@export var drag_sensitivity: float = 1.0
@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.5
@export var wasd_speed: float = 1200.0

var _dragging: bool = false
var _last_mouse_pos: Vector2 = Vector2.ZERO
var _tm: TileMap

func _ready() -> void:
	_tm = get_node_or_null(tilemap_path) as TileMap
	_update_limits_from_tilemap()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton

		# Start/stop panning
		if mb.button_index == pan_button:
			if mb.pressed:
				_dragging = true
				_last_mouse_pos = mb.position
			else:
				_dragging = false

		# Zoom na kursor
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var before: Vector2 = get_global_mouse_position()

			var z: float = zoom.x
			if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
				z = max(min_zoom, z * (1.0 - zoom_step))
			else:
				z = min(max_zoom, z * (1.0 + zoom_step))
			zoom = Vector2(z, z)

			var after: Vector2 = get_global_mouse_position()
			position += (before - after)
			_clamp_to_limits()

	elif event is InputEventMouseMotion and _dragging:
		var mm: InputEventMouseMotion = event as InputEventMouseMotion
		var delta_vec: Vector2 = mm.position - _last_mouse_pos
		position -= delta_vec * drag_sensitivity * zoom.x
		_last_mouse_pos = mm.position
		_clamp_to_limits()

func _process(delta: float) -> void:
	var dir: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_right"): dir.x += 1.0
	if Input.is_action_pressed("ui_left"):  dir.x -= 1.0
	if Input.is_action_pressed("ui_down"):  dir.y += 1.0
	if Input.is_action_pressed("ui_up"):    dir.y -= 1.0

	if dir != Vector2.ZERO:
		position += dir.normalized() * wasd_speed * delta * zoom.x
		_clamp_to_limits()

func _update_limits_from_tilemap() -> void:
	if _tm == null:
		return

	var r: Rect2i = _tm.get_used_rect()
	if r.size == Vector2i.ZERO:
		return

	var p0: Vector2 = _tm.map_to_local(r.position)
	var p1: Vector2 = _tm.map_to_local(r.position + Vector2i(r.size.x, 0))
	var p2: Vector2 = _tm.map_to_local(r.position + Vector2i(0, r.size.y))
	var p3: Vector2 = _tm.map_to_local(r.position + r.size)

	# ręczne min/max na floatach (bez Variant arrays)
	var minx: float = min(p0.x, p1.x); minx = min(minx, p2.x); minx = min(minx, p3.x)
	var maxx: float = max(p0.x, p1.x); maxx = max(maxx, p2.x); maxx = max(maxx, p3.x)
	var miny: float = min(p0.y, p1.y); miny = min(miny, p2.y); miny = min(miny, p3.y)
	var maxy: float = max(p0.y, p1.y); maxy = max(maxy, p2.y); maxy = max(maxy, p3.y)

	var margin: float = 64.0
	limit_left   = int(floor(minx - margin))
	limit_right  = int(ceil (maxx + margin))
	limit_top    = int(floor(miny - margin))
	limit_bottom = int(ceil (maxy + margin))
	# UWAGA: w Godot 4 nie ma 'limit_smoothed' → nic tu nie ustawiamy.

func _clamp_to_limits() -> void:
	position.x = clampf(position.x, float(limit_left), float(limit_right))
	position.y = clampf(position.y, float(limit_top),  float(limit_bottom))
