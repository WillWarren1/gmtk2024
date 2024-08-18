extends Node2D

@onready var atkPane = $AttackerPane
@onready var defPane = $DefenderPane
@onready var readoutPanel = $BattleMessage
@onready var atkHpCurrLabel = $AttackerPane/AttackerPanel/CurrHealthLabel
@onready var defHpCurrLabel = $DefenderPane/DefenderPanel/CurrHealthLabel

var attacker: Unit = null
var defender: Unit = null

var atkHpMax = 10
var atkHpCurr = 10
var atkStr = 1

var defHpMax = 10
var defHpCurr = 10
var defStr = 1

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
	defHpMax = defender.statsController.stats.maxHealth
	defHpCurr = defender.statsController.stats.currentHealth


func _process(delta):
	atkHpCurrLabel.text = str(atkHpCurr)
	defHpCurrLabel.text = str(defHpCurr)

	
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
			var ifHit = [0,1].pick_random()

			if ifHit == 0:
				step = 8
			else:
				step = 6
		6:
			readoutPanel.text = "ATTACKER HITS"
			await get_tree().create_timer(.5).timeout
			step = 7
		7:
			if damageDone == false:
				defHpCurr -= atkStr
				defender.statsController.stats.currentHealth = defHpCurr
				damageDone = true
			step = 10
		8:
			readoutPanel.text = "ATTACKER MISSES"
			step = 10
		10:
			await get_tree().create_timer(.5).timeout
			step = 11
		11:
			queue_free()
