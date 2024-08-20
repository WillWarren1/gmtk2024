extends Node2D

@onready var turnUI = $TurnUI

var playerArmy: Array
var playerArmyActive: Array
var enemyArmy: Array
var enemyArmyActive: Array
var turnArray: Array
var gameboard
var main
var activeUnit
var currentTurn = 0
var turnStep = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gameboard = get_tree().get_first_node_in_group("Gameboard")
	main = get_tree().get_first_node_in_group("Main")
	get_armies()
	create_turn_order()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#activeUnit = playerArmyActive[0]
	match turnStep:
		0:
			if currentTurn == turnArray.size():
				print("NEW ROUND!!!!")
				get_armies()
				create_turn_order()
			else:
				print("Turn " + str(currentTurn))
			turnStep = 1
		1:
			if is_instance_valid(turnArray[currentTurn]):
				snap_to_unit(turnArray[currentTurn])
				turnStep = 2
			else:
				iterate_turn()
		2:
			#gameboard._select_active_unit(turnArray[currentTurn].cell)
			if turnArray[currentTurn].isPlayerControllable:
				turnUI.activated = true
			else:
				enemy_ai(turnArray[currentTurn])
			turnStep = 3
		3:
			if !turnArray[currentTurn].isPlayerControllable:
				iterate_turn()
			else:
				if turnArray[currentTurn].isSelected == false:
					pass

	
	
	if Input.is_action_just_pressed("L"):
		main.camera.global_position = activeUnit.global_position
	if Input.is_action_just_pressed("P"):
		get_armies()
	if Input.is_action_just_pressed("S"):
		if playerArmyActive.size() > 0:
			playerArmyActive[0].store_unit("chungus")
	if Input.is_action_just_pressed("D"):
		for i in playerArmy:
			if i.isStored == true:
				i.deploy_unit(Vector2(640,640))
				break
	if Input.is_action_just_pressed("T"):
		create_turn_order()

func snap_to_unit(unit):
	print("SNAP")
	main.camera.global_position = unit.global_position

func iterate_turn():
	if is_instance_valid(turnArray[currentTurn]):
		turnArray[currentTurn].statsController.stats.currentMovementRange = turnArray[currentTurn].statsController.stats.maxMovementRange
	if gameboard._active_unit:
		gameboard._deselect_active_unit()
	print("Iterating Turn")
	if currentTurn < turnArray.size()-1:
		currentTurn += 1
		turnStep = 0
	else:
		currentTurn = 0
		turnStep = 0
	print("Current Turn is " + str(currentTurn))
	print("Current Step is " + str(turnStep))

func create_turn_order():
	turnArray.clear()
	var turn_length = maxi(playerArmyActive.size(),enemyArmyActive.size())
	for i in turn_length:
		if i < playerArmyActive.size():
			turnArray.append(playerArmyActive[i])
		if i < enemyArmyActive.size():
			turnArray.append(enemyArmyActive[i])
	print("Turn order is " + str(turnArray))
	print("Round length is " + str(turnArray.size()))

func get_armies():
	playerArmy.clear()
	playerArmyActive.clear()
	enemyArmy.clear()
	enemyArmyActive.clear()
	print("Updating Armies")
	
	for i in gameboard.get_children():
		if i.is_in_group("Unit"):
			if i.isPlayerControllable == true:
				playerArmy.append(i)
				if i.isStored == false:
					playerArmyActive.append(i)
			else:
				enemyArmy.append(i)
				if i.activeEnemy == true:
					enemyArmyActive.append(i)
	print("Player Army " + str(playerArmy))
	print("Player Units not Stored " + str(playerArmyActive))
	print("Enemy Army " + str(enemyArmy))
	print("Enemy Army Active " + str(enemyArmyActive))


func _on_end_turn_pressed() -> void:
	turnUI.activated = false
	iterate_turn()

func enemy_ai(unit):
	print("PEEPEE POOPOO! I AM " + str(unit) + "And it's my turn!")


func _on_moveand_atk_pressed() -> void:
	gameboard._active_unit = null
	gameboard._select_active_unit(turnArray[currentTurn].cell)
