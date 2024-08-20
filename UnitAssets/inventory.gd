extends Node

@onready var stats = $"../Stats"

var inventory = []

signal inventory_updated

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory.resize(stats.stats.inventorySize)

func add_item():
	inventory_updated.emit()
