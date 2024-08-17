extends Node2D

@onready var unit = $"../Unit"

func _process(delta):
	queue_redraw()

func _draw():
	if unit.currentPointPath.is_empty():
		return

	draw_polyline(unit.currentPointPath, Color.DARK_RED)
