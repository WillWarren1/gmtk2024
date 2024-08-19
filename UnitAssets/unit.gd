@tool
class_name Unit
extends Path2D

signal walk_finished

@export var grid: Resource = preload("res://Grid.tres")
#@export var skin: Texture: set = set_skin
@export var skinOffset := Vector2.ZERO: set = set_skin_offset
@export var isPlayerControllable := false
@export var hurtSprite: String = "infantryHurt"
@export var idleSprite: String = "infantryIdle"
@export var shootSprite: String = "infantryShoot"

var cell := Vector2.ZERO: set = set_cell
var base: Rect2
var isSelected := false: set = set_is_selected

var isWalking := false: set = _set_is_walking


@onready var _sprite: AnimatedSprite2D = $PathFollow2D/UnitSprite
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path_follow: PathFollow2D = $PathFollow2D
@onready var statsController: Node2D = $Stats
@onready var hurtTimer = $Timer
@onready var shootTimer = $Timer2

func _draw() -> void:
	draw_rect(base, Color.ALICE_BLUE, false, 1.0)


func _ready() -> void:

	print(grid.calculate_grid_coordinates(position))
	self.cell = grid.calculate_grid_coordinates(position)
	print('ready cell', cell)
	position = grid.calculate_map_position(cell)
	var size = statsController.stats.size
	base = grid.create_rectangle(cell, Vector2(size, size))
	print("base", base)

	if not Engine.is_editor_hint():
		curve = Curve2D.new()



func _process(delta: float) -> void:
	_path_follow.progress += statsController.stats.speed * delta

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


#func set_skin(value: Texture) -> void:
	#skin = value
	#if not _sprite:
		## The yield keyword allows us to wait until the unit node's `_ready()` callback ended.
		#await _ready()
	#_sprite.texture = value


func set_skin_offset(value: Vector2) -> void:
	skinOffset = value
	if not _sprite:
		# The yield keyword allows us to wait until the unit node's `_ready()` callback ended.
		await _ready()
	_sprite.position = value


func _set_is_walking(value: bool) -> void:
	isWalking = value
	set_process(isWalking)

func attack():
	_sprite.play(shootSprite)
	shootTimer.start()

func hurt(damage):
	_sprite.play(hurtSprite)
	hurtTimer.start()

func hurt_finished():
	_sprite.play(idleSprite)

func attack_finished() -> void:
	_sprite.play(idleSprite)
