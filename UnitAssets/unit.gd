@tool
class_name Unit
extends Path2D

signal walk_finished

@export var grid: Resource = preload("res://Grid.tres")
#@export var skin: Texture: set = set_skin
@export var skinOffset := Vector2.ZERO: set = set_skin_offset
@export var isPlayerControllable := false

var size := 1

@export var unitClass: String = "Infantry"
var hurtSprite: String = "infantryHurt"
var idleSprite: String = "infantryIdle"
var shootSprite: String = "infantryShoot"
var selectSound: String = "res://Audio/SFX/SoldierSelect.wav"
var walkSound: String = "res://Audio/SFX/SoldierMove.wav"
var shootSound: String = "res://Audio/SFX/SoldierShoot.wav"
var hitSound: String = "res://Audio/SFX/SoldierHit.wav"

var cell := Vector2.ZERO: set = set_cell
var base: Array
var isSelected := false: set = set_is_selected

var isWalking := false: set = _set_is_walking


@onready var _sprite: AnimatedSprite2D = $PathFollow2D/UnitSprite
@onready var _shadow_sprite: Sprite2D = $PathFollow2D/ShadowSprite
@onready var baseHighlighter: Sprite2D = $PathFollow2D/BaseHighlighter
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path_follow: PathFollow2D = $PathFollow2D
@onready var statsController: Node2D = $Stats
@onready var hurtTimer = $Timer
@onready var shootTimer = $Timer2
@onready var audioMove = $AudioMove
@onready var audioSelect = $AudioSelect

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
#func _draw() -> void:
	#draw_rect(base, Color.ALICE_BLUE, false, 1.0)


func _ready() -> void:
	if isPlayerControllable == false:
		scale.x = -1
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
			statsController.stats.speed = 400.0
			statsController.stats.maxHealth = 10
			statsController.stats.currentHealth = 10
			size = 1
			statsController.stats.currentAmmo = 6
			statsController.stats.maxAmmo = 6
			statsController.stats.defense = 2
			statsController.stats.attackCounter = 40
		"EnemyInfantry":
			hurtSprite = "enemyInfantryHurt"
			idleSprite = "enemyInfantryIdle"
			shootSprite = "enemyInfantryShoot"
			
			statsController.stats.weaponRange = 3
			statsController.stats.meleeRange = 1
			statsController.stats.weaponDamage = 3
			statsController.stats.meleeDamage = 1
			statsController.stats.movementRange = 6
			statsController.stats.speed = 600.0
			statsController.stats.maxHealth = 10
			statsController.stats.currentHealth = 10
			size = 1
			statsController.stats.currentAmmo = 6
			statsController.stats.maxAmmo = 6
			statsController.stats.defense = 2
			statsController.stats.attackCounter = 40
		"Mech":
			hurtSprite = "mechHurt"
			idleSprite = "mechIdle"
			shootSprite = "mechShoot"
			walkSound = "res://Audio/SFX/MechMove.wav"
			shootSound = "res://Audio/SFX/MechShoot.wav"
			hitSound = "res://Audio/SFX/MechHit.wav"
			selectSound = "res://Audio/SFX/MechSelect.wav"

			statsController.stats.weaponRange = 8
			statsController.stats.meleeRange = 3
			statsController.stats.weaponDamage = 8
			statsController.stats.meleeDamage = 3
			statsController.stats.movementRange = 10
			statsController.stats.speed = 500.0
			statsController.stats.maxHealth = 30
			statsController.stats.currentHealth = 30
			size = 5
			statsController.stats.currentAmmo = 12
			statsController.stats.maxAmmo = 12
			statsController.stats.defense = 3
			statsController.stats.attackCounter = 240
			_shadow_sprite.scale = Vector2(4, 4)
			_shadow_sprite.position.y = 64
			
		"EnemyMech":
			hurtSprite = "enemyMechHurt"
			idleSprite = "enemyMechIdle"
			shootSprite = "enemyMechShoot"
			walkSound = "res://Audio/SFX/MechMove.wav"
			shootSound = "res://Audio/SFX/MechShoot.wav"
			hitSound = "res://Audio/SFX/MechHit.wav"
			selectSound = "res://Audio/SFX/MechSelect.wav"
			statsController.stats.weaponRange = 8
			statsController.stats.meleeRange = 3
			statsController.stats.weaponDamage = 8
			statsController.stats.meleeDamage = 3
			statsController.stats.movementRange = 10
			statsController.stats.speed = 250.0
			statsController.stats.maxHealth = 30
			statsController.stats.currentHealth = 30
			size = 5
			statsController.stats.currentAmmo = 12
			statsController.stats.maxAmmo = 12
			statsController.stats.defense = 3
			statsController.stats.attackCounter = 240
			_shadow_sprite.scale = Vector2(4, 4)
			_shadow_sprite.position.y = 64
		"Carrier":
			hurtSprite = "carrierHurt"
			idleSprite = "carrierIdle"
			shootSprite = "carrierShoot"
			walkSound = "res://Audio/SFX/CarrierMove.wav"
			shootSound = "res://Audio/SFX/CarrierShoot.wav"
			hitSound = "res://Audio/SFX/CarrierHit.wav"
			selectSound = "res://Audio/SFX/CarrierSelect.wav"
			statsController.stats.weaponRange = 10
			statsController.stats.meleeRange = 0
			statsController.stats.weaponDamage = 4
			statsController.stats.meleeDamage = 0
			statsController.stats.movementRange = 14
			statsController.stats.speed = 200.0
			statsController.stats.maxHealth = 50
			statsController.stats.currentHealth = 50
			size = 13
			statsController.stats.currentAmmo = 24
			statsController.stats.maxAmmo = 24
			statsController.stats.defense = 4
			statsController.stats.attackCounter = 40
		"EnemyTurret":
			_sprite.position.y = -32
			hurtSprite = "enemyTurretHurt"
			idleSprite = "enemyTurretIdle"
			shootSprite = "enemyTurretShoot"
			walkSound = "res://Audio/SFX/MechMove.wav"
			shootSound = "res://Audio/SFX/MechShoot.wav"
			hitSound = "res://Audio/SFX/MechHit.wav"
			selectSound = "res://Audio/SFX/MechSelect.wav"
			
			statsController.stats.weaponRange = 13
			statsController.stats.meleeRange = 0
			statsController.stats.weaponDamage = 8
			statsController.stats.meleeDamage = 0
			statsController.stats.movementRange = 0
			statsController.stats.speed = 0.0
			statsController.stats.maxHealth = 30
			statsController.stats.currentHealth = 30
			size = 5
			statsController.stats.currentAmmo = 12
			statsController.stats.maxAmmo = 12
			statsController.stats.defense = 3
			statsController.stats.attackCounter = 240


	print(grid.calculate_grid_coordinates(position))
	self.cell = grid.calculate_grid_coordinates(position)
	#print('ready cell', cell)
	position = grid.calculate_map_position(cell)
	baseHighlighter.scale = Vector2(size, size)
	base = grid.makeCellSquare(cell, size)
	#print("base", base)

	if not Engine.is_editor_hint():
		curve = Curve2D.new()

	_sprite.play(idleSprite)
	audioMove.stream = load(walkSound)
	audioSelect.stream = load(selectSound)


func _process(delta: float) -> void:
	_path_follow.progress += statsController.stats.speed * delta
	base = grid.makeCellSquare(cell, size)

	if _path_follow.progress_ratio >= 1.0:
		self.isWalking = false
		_path_follow.progress = 0.0
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		emit_signal("walk_finished")
		audioMove.stop()


func walk_along(path: PackedVector2Array) -> void:
	print("path", path)
	if path.is_empty():
		return

	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	self.isWalking = true
	audioMove.play()


func set_cell(value: Vector2) -> void:
	cell = grid.clamp(value)


func set_is_selected(value: bool) -> void:
	isSelected = value
	if isSelected:
		_anim_player.play("selected")
		audioSelect.play()
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
