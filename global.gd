extends Node


enum UnitClass {
	INFANTRY,
	MECH,
	CARRIER,
	ENEMYINFANTRY,
	ENEMYMECH,
	ENEMYTURRET
}

var turnOrder = []

enum turnTakers {
	PLAYER,
	ENEMY
}
