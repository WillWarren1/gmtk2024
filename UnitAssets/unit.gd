@tool
class_name Unit
extends Path2D

signal walk_finished

@export var grid: Resource = preload("res://Grid.tres")
#@export var skin: Texture: set = set_skin
@export var skinOffset := Vector2.ZERO: set = set_skin_offset
@export var isPlayerControllable := false
@export var unitClass: String = "Infantry"
var hurtSprite: String = "infantryHurt"
var idleSprite: String = "infantryIdle"
var shootSprite: String = "infantryShoot"

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
	
	match unitClass:
		"Infantry":
			hurtSprite = "infantryHurt"
			idleSprite = "infantryIdle"
			shootSprite = "infantryShoot"
			
			statsController.stats.weaponRange = 3
			statsController.stats.meleeRange = 1
			statsController.stats.weaponDamage = 3
			statsController.stats.meleeDamage = 1
			statsController.stats.movementRange = 6
			statsController.stats.speed = 600.0
			statsController.stats.maxHealth = 10
			statsController.stats.currentHealth = 10
			statsController.stats.size = 1
			statsController.stats.currentAmmo = 6
			statsController.stats.maxAmmo = 6
			statsController.stats.defense = 2
		"Mech":
			hurtSprite = "mechHurt"
			idleSprite = "mechIdle"
			shootSprite = "mechShoot"
			
			statsController.stats.weaponRange = 8
			statsController.stats.meleeRange = 3
			statsController.stats.weaponDamage = 8
			statsController.stats.meleeDamage = 3
			statsController.stats.movementRange = 10
			statsController.stats.speed = 500.0
			statsController.stats.maxHealth = 30
			statsController.stats.currentHealth = 10
			statsController.stats.size = 5
			statsController.stats.currentAmmo = 12
			statsController.stats.maxAmmo = 12
			statsController.stats.defense = 3
		"Carrier":
			hurtSprite = "carrierHurt"
			idleSprite = "carrierIdle"
			shootSprite = "carrierShoot"
			
			statsController.stats.weaponRange = 10
			statsController.stats.meleeRange = 0
			statsController.stats.weaponDamage = 4
			statsController.stats.meleeDamage = 0
			statsController.stats.movementRange = 14
			statsController.stats.speed = 400.0
			statsController.stats.maxHealth = 50
			statsController.stats.currentHealth = 50
			statsController.stats.size = 13
			statsController.stats.currentAmmo = 24
			statsController.stats.maxAmmo = 24
			statsController.stats.defense = 4



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
	if statsController.stats.currentHealth > 0:
		hurtTimer.start()
	else:
		queue_free()

func hurt_finished():
	_sprite.play(idleSprite)

func attack_finished() -> void:
	_sprite.play(idleSprite)
