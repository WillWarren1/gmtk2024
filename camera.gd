extends Camera2D

@export var grid: Resource = preload("res://Grid.tres")

var mouse_pos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = Vector2(640,480)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos.x > 1900:
		if global_position.x < grid.size.x * grid.cell_size.x - 480:
			global_position.x += 4
	if mouse_pos.x < 20:
		if global_position.x > 480:
			global_position.x -= 4
	if mouse_pos.y > 1060:
		if global_position.y < grid.size.y * grid.cell_size.y - 270:
			global_position.y += 4
	if mouse_pos.y < 20:
		if global_position.y > 270:
			global_position.y -= 4
