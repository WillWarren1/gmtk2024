extends Node2D

var mainscene = preload("res://Main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	var chungus = mainscene.instantiate()
	chungus.global_position = Vector2(0,0)
	add_sibling(chungus)
	queue_free()
