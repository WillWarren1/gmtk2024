extends Node2D

# controls number of turns in a round
var numberOfUnits: int
# round resets when unitsUsed equals numberOfUnits
var unitsUsed: int

var turnIndex = 0

var currentTurnTaker

signal new_round

func _ready() -> void:
#	loop through units every turn, but if the next turnTaker has no units just re-enable active turnTaker's units
	var turnOrder = [
		Global.turnTakers.PLAYER,
		Global.turnTakers.ENEMY
	]
	setTurnOrder(turnOrder)

func _process(delta: float) -> void:
	currentTurnTaker = Global.turnOrder[turnIndex]

func resetTurnOrder() -> void:
	Global.turnOrder = []

func setTurnOrder(newOrder: Array) -> void:
	Global.turnOrder = newOrder

func resetNumberOfUnits() -> void:
	numberOfUnits = 0

func addUnits(count: int = 1) -> void:
	numberOfUnits += count

func subtractUnits(count: int) -> void:
	numberOfUnits -= count

func resetUnitsUsed() -> void:
	unitsUsed = 0

func addUnitsUsed(count: int = 1) -> void:
	unitsUsed += count

func subtractUnitsUsed(count: int = 1) -> void:
	unitsUsed -= count

func reverseTurnOrder() -> void:
#	If active turnTaker does not have enough active units, a signal can be emitted and TurnTracker will reverse the turn order,
 #functionally skipping the turn of the turnTaker with no active units left
	var turnOrder = [Global.turnOrder.back(), Global.turnOrder.front()]
	setTurnOrder(turnOrder)

func startNewTurn() -> void:
	if turnIndex == 0:
		turnIndex = 1
	else:
		turnIndex = 0
	print("NEW TURN")


func _on_unit_turn_finished():
	print("unitsUsed ", unitsUsed)
	print("number of units 0", numberOfUnits)
	addUnitsUsed(1)
#	todo: CHANGE NUMBER OF UNITS TO NUMBER OF CURRENT COMMANDER UNITS <--- this does not exist yet, will require set up
	if unitsUsed >= numberOfUnits:
		print('unitsUsed', unitsUsed)
		print('numberOfUnits', numberOfUnits)
		resetUnitsUsed()
		emit_signal("new_round")
		startNewTurn()
		print("RESET ROUND")
	else:
		print("new turn")
		startNewTurn()
