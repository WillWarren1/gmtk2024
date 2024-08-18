@tool
class_name Unit
extends Path2D

signal walk_finished

@export var grid: Resource = preload("res://Grid.tres")
@export var skin: Texture: set = set_skin
@export var moveRange := 6
@export var skinOffset := Vector2.ZERO: set = set_skin_offset
@export var moveSpeed := 600.0
@export var isPlayerControllable := false

var cell := Vector2.ZERO: set = set_cell
var isSelected := false: set = set_is_selected

var isWalking := false: set = _set_is_walking

@onready var _sprite: Sprite2D = $PathFollow2D/UnitSprite
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path_follow: PathFollow2D = $PathFollow2D


func _ready() -> void:
	set_process(false)

	print(grid.calculate_grid_coordinates(position))
	self.cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)

	if not Engine.is_editor_hint():
		curve = Curve2D.new()





func _process(delta: float) -> void:
	_path_follow.progress += moveSpeed * delta

	if _path_follow.progress_ratio >= 1.0:
		self.isWalking = false
		_path_follow.progress = 0.0
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		emit_signal("walk_finished")


func walk_along(path: PackedVector2Array) -> void:
	if path.is_empty():
		return

	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	self.isWalking = true


func set_cell(value: Vector2) -> void:
	cell = grid.clamp(value)


func set_is_selected(value: bool) -> void:
	isSelected = value
	if isSelected:
		_anim_player.play("selected")
	else:
		_anim_player.play("idle")


func set_skin(value: Texture) -> void:
	skin = value
	if not _sprite:
		# The yield keyword allows us to wait until the unit node's `_ready()` callback ended.
		await _ready()
	_sprite.texture = value


func set_skin_offset(value: Vector2) -> void:
	skinOffset = value
	if not _sprite:
		# The yield keyword allows us to wait until the unit node's `_ready()` callback ended.
		await _ready()
	_sprite.position = value


func _set_is_walking(value: bool) -> void:
	isWalking = value
	set_process(isWalking)
