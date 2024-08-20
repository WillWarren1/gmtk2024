extends Node2D

var playerArmy: Array
var playerArmyActive: Array
var enemyArmy: Array
var enemyArmyActive: Array
var turnArray: Array
var gameboard
var main
var activeUnit
var currentTurn = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gameboard = get_tree().get_first_node_in_group("Gameboard")
	main = get_tree().get_first_node_in_group("Main")
	get_armies()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#activeUnit = playerArmyActive[0]
	
	
	
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
	main.camera.global_position = unit.global_position

func iterate_turn():
	if currentTurn < turnArray.size():
		currentTurn += 1
		snap_to_unit(turnArray)

func create_turn_order():
	turnArray.clear()
	var turn_length = maxi(playerArmyActive.size(),enemyArmyActive.size())
	for i in turn_length:
		if i < playerArmyActive.size():
			turnArray.append(playerArmyActive[i])
		if i < enemyArmyActive.size():
			turnArray.append(enemyArmyActive[i])
	print("Turn order is " + str(turnArray))

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
