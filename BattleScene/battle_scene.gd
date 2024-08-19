extends Control

var camera

@onready var atkPane: Node2D = $AttackerPane
@onready var atkAnimSprite: AnimatedSprite2D = $AttackerPane/AttackerPanel/AnimatedSprite2D
@onready var defPane: Node2D = $DefenderPane
@onready var defAnimSprite: AnimatedSprite2D = $DefenderPane/DefenderPanel/AnimatedSprite2D
@onready var readoutPanel: Label = $BattleMessage
@onready var atkHpCurrLabel: Label = $AttackerPane/AttackerPanel/CurrHealthLabel
@onready var defHpCurrLabel: Label = $DefenderPane/DefenderPanel/CurrHealthLabel

var attacker: Unit = null
var defender: Unit = null

var atkHpMax = 10
var atkHpCurr = 10
var atkStr = 1

var defHpMax = 10
var defHpCurr = 10
var defStr = 1
var defDefense

var step = 0

var atkPaney
var defPaney

var counter = 0
var damageDone = false

func _ready():
	atkPaney = atkPane.position.y
	defPaney = defPane.position.y
	atkPane.position.y -= 500
	defPane.position.y += 500

	atkStr = attacker.statsController.stats.weaponDamage
	atkHpMax = attacker.statsController.stats.maxHealth
	atkHpCurr = attacker.statsController.stats.currentHealth

	defStr = defender.statsController.stats.weaponDamage
	defDefense = defender.statsController.stats.defense
	defHpMax = defender.statsController.stats.maxHealth
	defHpCurr = defender.statsController.stats.currentHealth
	camera = get_tree().get_first_node_in_group("Camera")


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
			readoutPanel.text = "ATTACKER ATTACKS FOR " + str(atkStr)
			step = 3
		3:
			await get_tree().create_timer(.5).timeout
			step = 4
		4:
			print("ANIMATION")
			counter += 1
			if counter >= 10:
				step = 5
		5:
			var ifHit = d6()

			if ifHit <= defDefense:
				step = 8
			else:
				step = 6
		6:
			readoutPanel.text = "ATTACKER HITS FOR " + str(atkStr)
			await get_tree().create_timer(.5).timeout
			step = 7
		7:
			if damageDone == false:
				defHpCurr -= atkStr
				defender.statsController.stats.currentHealth = defHpCurr
				damageDone = true
			step = 10
		8:
			readoutPanel.text = "ATTACKER GRAZES FOR 1"
			if damageDone == false:
				defHpCurr -= atkStr
				defender.statsController.stats.currentHealth = defHpCurr
				damageDone = true
			step = 10
		10:
			await get_tree().create_timer(.5).timeout
			step = 11
		11:
			queue_free()
			pass

func d6() -> int:
	return [1,2,3,4,5,6].pick_random()
