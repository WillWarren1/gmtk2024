extends Node2D

# controls number of turns in a round
var numberOfUnits: int
# round resets when unitsUsed equals numberOfUnits
var unitsUsed: int



func _ready() -> void:
#	loop through units every turn, but if the next turnTaker has no units just re-enable active turnTaker's units
	var turnOrder = [
		Global.turnTakers.PLAYER,
		Global.turnTakers.ENEMY
	]
	setTurnOrder(turnOrder)


func resetTurnOrder() -> void:
	Global.turnOrder = []

func setTurnOrder(newOrder: Array) -> void:
	Global.turnOrder = newOrder

func subtractUnits(count: int) -> void:
	numberOfUnits -= count

func addUnitsUsed(count: int = 1) -> void:
	unitsUsed += count

func reverseTurnOrder() -> void:
#	If active turnTaker does not have enough active units, a signal can be emitted and TurnTracker will reverse the turn order,
 #functionally skipping the turn of the turnTaker with no active units left
	var turnOrder = [Global.turnOrder.back(), Global.turnOrder.front()]
	setTurnOrder(turnOrder)
