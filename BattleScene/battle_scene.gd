extends Control

var camera

@onready var atkPane: Node2D = $AttackerPane
@onready var atkAnimSprite: AnimatedSprite2D = $AttackerPane/AttackerPanel/AttackerSprite
@onready var defPane: Node2D = $DefenderPane
@onready var defAnimSprite: AnimatedSprite2D = $DefenderPane/DefenderPanel/DefenderSprite
@onready var readoutPanel: Label = $BattleMessage
@onready var atkHpCurrLabel: Label = $AttackerPane/AttackerPanel/CurrHealthLabel
@onready var atkHpMaxLabel: Label = $AttackerPane/AttackerPanel/MaxHealthLabel
@onready var defHpCurrLabel: Label = $DefenderPane/DefenderPanel/CurrHealthLabel
@onready var defHpMaxLabel: Label = $AttackerPane/AttackerPanel/MaxHealthLabel
@onready var atkAudio = $AttackerPane/AttackAudio
@onready var defAudio = $DefenderPane/DefendAudio

var attacker: Unit = null
var defender: Unit = null

var atkHpMax
var atkHpCurr
var atkStr = 1
var atkIdle = "infantryIdle"
var atkShoot = "infantryShoot"
var atkHurt = "infantryHurt"

var defHpMax
var defHpCurr
var defStr = 1
var defDefense = 1
var defIdle = "infantryIdle"
var defShoot = "infantryShoot"
var defHurt = "infantryHurt"

var step = 0

var atkPaney
var defPaney

var counter = 24
var damageDone = false

var atkAudioPlaying = false
var defAudioPlaying = false

func _ready():
	atkIdle = attacker.idleSprite
	atkShoot = attacker.shootSprite
	atkHurt = attacker.hurtSprite
	
	atkPaney = atkPane.position.y
	defPaney = defPane.position.y
	atkPane.position.y -= 500
	defPane.position.y += 500

	atkStr = attacker.statsController.stats.weaponDamage
	atkHpMax = attacker.statsController.stats.maxHealth
	atkHpCurr = attacker.statsController.stats.currentHealth
	atkAudio.stream = load(attacker.shootSound)
	counter = attacker.statsController.stats.attackCounter

	defStr = defender.statsController.stats.weaponDamage
	defDefense = defender.statsController.stats.defense
	defHpMax = defender.statsController.stats.maxHealth
	defHpCurr = defender.statsController.stats.currentHealth
	defAudio.stream = load(attacker.hitSound)
	camera = get_tree().get_first_node_in_group("Camera")
	
	if attacker.unitClass == "Mech":
		atkAnimSprite.scale = Vector2(2,2)
		defAnimSprite.scale = Vector2(-2,2)
	if attacker.unitClass == "Carrier":
		atkAnimSprite.scale = Vector2(1,1)
		defAnimSprite.scale = Vector2(-1,1)
	atkAnimSprite.play(atkIdle)
	defAnimSprite.play(defIdle)


func _process(delta):
	
	atkHpCurrLabel.text = str(atkHpCurr)
	defHpCurrLabel.text = str(defHpCurr)

	global_position = camera.global_position

	if camera.zoom_level == 2:
		scale = Vector2(.5,.5)
	elif camera.zoom_level == 1.75:
		scale = Vector2(.625,.625)
	elif camera.zoom_level == 1.5:
		scale = Vector2(.75,.75)
	elif camera.zoom_level == 1.25:
		scale = Vector2(.875,.875)
	elif camera.zoom_level == 1:
		scale = Vector2(1,1)


	match step:
		0:
			atkPane.position.y += 10
			defPane.position.y -= 10

			if atkPane.position.y >= atkPaney:
				atkPane.position.y = atkPaney
				defPane.position.y = defPaney
				step = 1
		1:
			await get_tree().create_timer(.5).timeout
			step = 2
		2:
			atkAnimSprite.play(atkShoot)
			attacker.attack()
			readoutPanel.text = "ATTACKER ATTACKS FOR " + str(atkStr)
			step = 3
		3:
			await get_tree().create_timer(.5).timeout
			if not atkAudioPlaying:
				atkAudio.play()
				print("Playing")
				atkAudioPlaying = true
			step = 4
		4:
			counter -= 1
			if counter <= 0:
				step = 5
				counter = 160
		5:
			var ifHit = d6()
			if ifHit == 6:
				print("CRIT")
				step = 7
			elif ifHit <= defDefense:
				step = 8
			else:
				step = 6
			defAnimSprite.play(defHurt)
			if not defAudioPlaying:
				defAudio.play()
				print("Playing2")
				defAudioPlaying = true
		6:
			readoutPanel.text = "ATTACKER HITS FOR " + str(atkStr)
			if damageDone == false:
				defHpCurr -= atkStr
				defender.statsController.stats.currentHealth = defHpCurr
				defender.hurt(atkStr)
				damageDone = true
			step = 10
		7:
			readoutPanel.text = "CRITICAL HIT! " + str(atkStr + floor(atkStr/2)) + " DAMAGE!"
			if damageDone == false:
				defHpCurr -= atkStr
				defender.statsController.stats.currentHealth = defHpCurr
				defender.hurt(atkStr + floor(atkStr/2))
				damageDone = true
			step = 10
		8:
			readoutPanel.text = "ATTACKER GRAZES FOR 1"
			if damageDone == false:
				defHpCurr -= 1
				defender.statsController.stats.currentHealth = defHpCurr
				defender.hurt(1)
				damageDone = true
			step = 10
		10:
			atkAnimSprite.play(atkIdle)
			counter -= 1
			if counter <= 0:
				step = 11
				counter = 36
		11:
			queue_free()
			pass

func d6() -> int:
	return [1,2,3,4,5,6].pick_random()
	
