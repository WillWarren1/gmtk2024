extends Panel

var activated = false
@onready var endTurnButton = $EndTurn
@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = get_parent().main.camera.global_position + Vector2(256,-128)
	if activated == true:
		if get_tree().get_first_node_in_group("BattleScene"):
			visible = false
		elif get_parent().deployMode == true:
			visible = false
		elif visible == false:
			visible = true
		if is_instance_valid(get_parent().turnArray[get_parent().currentTurn]):
			if get_parent().turnArray[get_parent().currentTurn].inventory <= 0:
				$Deploy.position.x = -100000
			else:
				$Deploy.position.x = 12
			label.text = str(get_parent().turnArray[get_parent().currentTurn].unitClass) + "'s Turn"
	else:
		if visible == true:
			visible = false
