extends Node2D

@onready var atkPane = $AttackerPane
@onready var defPane = $DefenderPane
@onready var readoutPanel = $BattleMessage
@onready var atkHpCurrLabel = $AttackerPane/AttackerPanel/CurrHealthLabel
@onready var defHpCurrLabel = $DefenderPane/DefenderPanel/CurrHealthLabel

var atkHpMax = 10
var atkHpCurr = 10
var atkStr = 1

var defHpMax = 10
var defHpCurr = 10
var defDef = 1

var step = 0

var atkPaney
var defPaney

var counter = 0

func _ready():
	atkPaney = atkPane.position.y
	defPaney = defPane.position.y
	atkPane.position.y -= 500
	defPane.position.y += 500


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
				step = 10
			else:
				step = 6
		6:
			readoutPanel.text = "ATTACKER HITS"
			await get_tree().create_timer(.5).timeout
			step = 7
		7:
			defHpCurrLabel.text = str(defHpCurr - atkStr)
		8:
			await get_tree().create_timer(.5).timeout
			step = 11
		10:
			await get_tree().create_timer(.5).timeout
			step = 11
		11:
			queue_free()
