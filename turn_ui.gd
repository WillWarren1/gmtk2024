extends Panel

var activated = false
@onready var endTurnButton = $EndTurn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = get_parent().main.camera.global_position + Vector2(256,-128)
	if activated == true:
		if visible == false:
			visible = true
	else:
		if visible == true:
			visible = false
