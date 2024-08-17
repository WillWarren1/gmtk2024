extends Node2D

@onready var tile_map = $"../TileMap"

var astarGrid: AStarGrid2D
var currentIdPath: Array[Vector2i]
var currentPointPath: PackedVector2Array
var targetPosition: Vector2
var isMoving: bool
var speed = 1

func _ready() -> void:
#	grid setup
	astarGrid = AStarGrid2D.new()
	astarGrid.region = tile_map.get_used_rect()
	astarGrid.cell_size = Vector2(16, 16)
	astarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astarGrid.update()

	# get walkable terrain
	for x in tile_map.get_used_rect().size.x:
		for y in tile_map.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_map.get_used_rect().position.x,
				y + tile_map.get_used_rect().position.y
			)

			var tile_data = tile_map.get_cell_tile_data(0, tile_position)

			if tile_data == null or tile_data.get_custom_data("walkable") == false:
				astarGrid.set_point_solid(tile_position)


func _input(event) -> void:
#	don't move if no move
	if event.is_action_pressed("move") == false:
		return

	var id_path
#	set path to target location when moving, otherwise set path to current position to trigger a stop
	if isMoving:
		id_path = astarGrid.get_id_path(
			tile_map.local_to_map(targetPosition),
			tile_map.local_to_map(get_global_mouse_position())
		)
	else:
		id_path = astarGrid.get_id_path(
			tile_map.local_to_map(global_position),
			tile_map.local_to_map(get_global_mouse_position())
		).slice(1)

	if id_path.is_empty() == false:
		currentIdPath = id_path

		currentPointPath = astarGrid.get_point_path(
			tile_map.local_to_map(targetPosition),
			tile_map.local_to_map(get_global_mouse_position())
		)


func _physics_process(delta):
	# no path? no move
	if currentIdPath.is_empty():
		return

	# if not moving, you are allow to move along path if one is created
	if isMoving == false:
		targetPosition = tile_map.map_to_local(currentIdPath.front())
		isMoving = true

	global_position = global_position.move_toward(targetPosition, speed)

	# if you have progressed, remove the current tile from path
	if global_position == targetPosition:
		currentIdPath.pop_front()

		if currentIdPath.is_empty() == false:
			targetPosition = tile_map.map_to_local(currentIdPath.front())
		else:
			isMoving = false
