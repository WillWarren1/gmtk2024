# Represents and manages the game board. Stores references to entities that are in each cell and
# tells whether cells are occupied or not.
# Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

# Once again, we use our grid resource that we explicitly define in the class.
@export var grid: Resource = preload("res://Grid.tres")
@export var combatScene: PackedScene = preload("res://BattleScene/battle_scene.tscn")
@onready var _unit_path: UnitPath = $UnitPath
@onready var _unit_overlay: UnitOverlay = $UnitOverlay
@onready var _target_overlay: TargetOverlay = $TargetOverlay
@onready var tileMap: TileMap = $"../TileMap"
@onready var cursor: Node2D = $Cursor

# This constant represents the directions in which a unit can move on the board. We will reference
# the constant later in the script.
const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
# The board is going to move one unit at a time. When we select a unit, we will save it as our
# `_active_unit` and populate the walkable cells below. This allows us to clear the unit, the
# overlay, and the interactive path drawing later on when the player decides to deselect it.
var _active_unit: Unit

var _hovered_unit: Unit
# This is an array of all the cells the `_active_unit` can move to. We will populate the array when
# selecting a unit and use it in the `_move_active_unit()` function below.
var _walkable_cells := []
var _targetable_cells := []
# var exclusionZone := []
var _unit_base: Array

var _pathfinder: PathFinder


# We use a dictionary to keep track of the units that are on the board. Each key-value pair in the
# dictionary represents a unit. The key is the position in grid coordinates, while the value is a
# reference to the unit.
# Mapping of coordinates of a cell to a reference to the unit it contains.
var _units := {}


# At the start of the game, we initialize the game board. Look at the `_reinitialize()` function below.
# It populates our `_units` dictionary.
func _ready() -> void:
	_reinitialize()


func _process(_delta: float) -> void:
	_reinitialize()
	if _units.has(cursor.cell):
		_hovered_unit = _units[cursor.cell]
		cursor.targetSprite.visible = false
		_hovered_unit.baseHighlighter.visible = true
	else:
		if !cursor.targetSprite.visible:
			cursor.targetSprite.visible = true
		if _hovered_unit && is_instance_valid(_hovered_unit) && _hovered_unit.baseHighlighter.visible:
			_hovered_unit.baseHighlighter.visible = false
		_hovered_unit = null

# Returns `true` if the cell is occupied by a unit.
func is_occupied(cell: Vector2) -> bool:
	return true if _units.has(cell) else false


# Clears, and refills the `_units` dictionary with game objects that are on the board.
func _reinitialize() -> void:
	_units.clear()

	# we loop over the node's children and filter them to find the units. As your game
	# becomes more complex, you may want to use the node group feature instead to place your units
	# anywhere in the scene tree.
	for child in get_children():
		# We can use the "as" keyword to cast the child to a given type. If the child is not of type
		# Unit, the variable will be null.
		var unit := child as Unit
		if not unit:
			continue
		# As mentioned when introducing the units variable, we use the grid coordinates for the key
		# and a reference to the unit for the value. This allows us to access a unit given its grid
		# coordinates.
		_units[unit.cell] = unit
#		todo add rect cells
		#print("unit.base", unit.base)
		for baseCell in unit.base:
			_units[baseCell] = unit

func removeCellsFromList(excludeList: Array, originList: Array) -> Array:
	for cellToExclude in excludeList:
		if originList.has(cellToExclude):
			originList.erase(cellToExclude)
	return originList

# Returns an array of cells a given unit can walk using the flood fill algorithm.
func get_walkable_cells(unit: Unit) -> Array:
	return _flood_fill(unit.cell, unit.statsController.stats.currentMovementRange)

func get_targetable_cells(unit: Unit) -> Array:
	var totalRange = unit.statsController.stats.currentMovementRange + unit.statsController.stats.weaponRange
	var isForAttacking = true
	return _flood_fill(unit.cell, totalRange, isForAttacking)

# Returns an array with all the coordinates of walkable cells based on the `max_distance`.
func _flood_fill(anchorCell: Vector2, max_distance: int, isForAttacking: bool = false) -> Array:
	# This is the array of walkable cells the algorithm outputs.
	var array := []
	var exclusionZone := []
	# The way we implemented the flood fill here is by using a stack. In that stack, we store every
	# cell we want to apply the flood fill algorithm to.
	var stack := [anchorCell]
	# We loop over cells in the stack, popping one cell on every loop iteration.
	while not stack.is_empty():
		var current = stack.pop_back()

		# For each cell, we ensure that we can fill further.
		#
		# The conditions are:
		# 1. We didn't go past the grid's limits.
		# 2. We haven't already visited and filled this cell
		# 3. We are within the `max_distance`, a number of cells.
		if not grid.is_within_bounds(current):
			continue
		if current in array:
			continue

		# This is where we check for the distance between the starting `cell` and the `current` one.
		var difference: Vector2 = (current - anchorCell).abs()
		var distance := int(difference.x + difference.y)
		if distance > max_distance:
			continue

		var tileData = tileMap.get_cell_tile_data(0, current)
		var isWalkable = false
		var unit = _units[anchorCell]
		if unit.unitClass ==Global.UnitClass.INFANTRY:
			isWalkable = tileData != null && tileData.get_custom_data("isSmallUnitWalkable")
		elif unit.unitClass == Global.UnitClass.MECH:
			isWalkable = tileData != null && tileData.get_custom_data("isMedUnitWalkable")
		elif unit.unitClass ==Global.UnitClass.CARRIER:
			isWalkable = tileData != null && tileData.get_custom_data("isBigUnitWalkable")
		if !isWalkable:
			continue

		# If we meet all the conditions, we "fill" the `current` cell. To be more accurate, we store
		# it in our output `array` to later use them with the UnitPath and UnitOverlay classes.
		array.append(current)
		# We then look at the `current` cell's neighbors and, if they're not occupied and we haven't
		# visited them already, we add them to the stack for the next iteration.
		# This mechanism keeps the loop running until we found all cells the unit can walk.
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			# This is an "optimization". It does the same thing as our `if current in array:` above
			# but repeating it here with the neighbors skips some instructions.
			if is_occupied(coordinates) && _units[coordinates] != _units[anchorCell]:
				# this next stuff just marks the tiles around that unit for exclusion from the flood fill
				# this prevents larger units from visually hiding smaller units
				var individualExclusionZone = grid.makeCellSquare(coordinates, _units[anchorCell].size)
				exclusionZone.append_array(individualExclusionZone)
				if !isForAttacking:
					continue
				elif _units[coordinates].isPlayerControllable:
					continue

			var targetDifference: Vector2 = (current - anchorCell).abs()
			var distanceFromCell := int(targetDifference.x + targetDifference.y)

			if distanceFromCell > _active_unit.statsController.stats.currentMovementRange:
				if isForAttacking:
					#print("distanceFromCell", distanceFromCell)
					exclusionZone.append(coordinates)
			if coordinates in array:
				continue

			# This is where we extend the stack.
			stack.append(coordinates)

	if !isForAttacking:
#		the exclusionZone is a zone of cells that we don't want units to navigate to
#		removing any cell from an exclusionzone prevents visual issues from larger units occupying the space next to smaller ones.
		#print("removing cells...")
		array = removeCellsFromList(exclusionZone, array)
		#print("done removing cells.")


#	now run through pathfinding for every cell in array, if theres no valid path to cell, remove it from array.
	_pathfinder = PathFinder.new(grid, array)
	var finalFilterList := []
	for floodCell in array:
		var floodPath: PackedVector2Array = _pathfinder.calculate_point_path(anchorCell, floodCell)
		print('floodpath size for cell ', floodCell, ' = ', floodPath.size())
		if floodCell == Vector2(32, 18):
			print('floodpath = ', floodPath)
		if floodPath.size() == 0:
			print("no floodpath found", anchorCell)
			finalFilterList.append(floodCell)
	return array.filter(func(potentiallyYuckyTile): return !finalFilterList.has(potentiallyYuckyTile))

# Selects the unit in the `cell` if there's one there.
# Sets it as the `_active_unit` and draws its walkable cells and interactive move path.
# The board reacts to the signals emitted by the cursor. And it does so by calling functions that
# select and move a unit.
func _select_active_unit(cell: Vector2) -> void:
	# Here's some optional defensive code: we return early from the function if the unit's not
	# registered in the `cell`.
	if not _units.has(cell):
		return

	if _units[cell].isPlayerControllable:
		# When selecting a unit, we turn on the overlay and path drawing. We could use signals on the
		# unit itself to do so, but that would split the logic between several files without a big
		# maintenance benefit and we'd need to pass extra data to the unit.
		# I decided to group everything in the GameBoard class because it keeps all the selection logic
		# in one place. I find it easy to keep track of what the class does this way.
		_active_unit = _units[cell]
		_unit_base = _units[cell].base
		_active_unit.isSelected = true
		_walkable_cells = get_walkable_cells(_active_unit)
		_unit_overlay.draw(_walkable_cells)
		_targetable_cells = get_targetable_cells(_active_unit)
		_target_overlay.draw(_targetable_cells)
		var _pathable_cells = get_walkable_cells(_active_unit)
		_unit_path.initialize(_pathable_cells)

func _select_target_unit(cell: Vector2) -> void:
	# Here's some optional defensive code: we return early from the function if the unit's not
	# registered in the `cell`.
	if not _units.has(cell):
		return
	if _units[cell].isPlayerControllable == true:
		return

#	We check the distance from any cell in the base of the target to the active units cell
	var baseCellDistances = []
	for baseCell in _units[cell].base:
		var distanceToBaseCell = floor(baseCell.distance_to(_active_unit.cell))
		baseCellDistances.append(distanceToBaseCell)

	var distance = floor(baseCellDistances.min())

	var weaponRange = _active_unit.statsController.stats.weaponRange
	var meleeRange = _active_unit.statsController.stats.meleeRange

	if distance <= weaponRange && distance > meleeRange:

		var combatInstance = combatScene.instantiate()
		combatInstance.position = get_viewport_rect().size / 2
		combatInstance.attacker = _active_unit
		combatInstance.defender = _units[cell]
		add_child(combatInstance)
		_deselect_active_unit()
		_clear_active_unit()
	elif distance <= meleeRange:
		print("within melee range")
		var combatInstance = combatScene.instantiate()
		combatInstance.position = get_viewport_rect().size / 2
		combatInstance.attacker = _active_unit
		combatInstance.defender = _units[cell]
		add_child(combatInstance)
		_deselect_active_unit()
		_clear_active_unit()

# Deselects the active unit, clearing the cells overlay and interactive path drawing.
# We need it for the `_move_active_unit()` function below, and we'll use it again in a moment.
func _deselect_active_unit() -> void:
	_active_unit.isSelected = false
	_unit_overlay.clear()
	_target_overlay.clear()
	_unit_path.stop()


# Clears the reference to the _active_unit and the corresponding walkable cells.
# We need it for the `_move_active_unit()` function below.
func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()


# Updates the _units dictionary with the target position for the unit and asks the _active_unit to
# walk to it.
func _move_active_unit(new_cell: Vector2) -> void:
	if (is_occupied(new_cell) && _units[new_cell] != _active_unit) or not new_cell in _walkable_cells:
		return

	# When moving a unit, we need to update our `_units` dictionary. We instantly save it in the
	# target cell even if the unit itself will take time to walk there.
	# While it's walking, the player won't be able to issue new commands.
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	# We also deselect it, clearing up the overlay and path.
	_deselect_active_unit()
	# We then ask the unit to walk along the path stored in the UnitPath instance and wait until it
	# finished.
	_active_unit.walk_along(_unit_path.current_path)
	await _active_unit.walk_finished
	_reinitialize()
	# Finally, we clear the `_active_unit`, which also clears the `_walkable_cells` array.
	_clear_active_unit()

# Updates the interactive path's drawing if there's an active and selected unit.
func _on_cursor_moved(new_cell: Vector2) -> void:
	# When the cursor moves, and we already have an active unit selected, we want to update the
	# interactive path drawing.
	if _active_unit and _active_unit.isSelected:
		_unit_path.draw(_active_unit.cell, new_cell)

# Selects or moves a unit based on where the cursor is.
func _on_cursor_accept_pressed(cell: Vector2) -> void:
	# The cursor's "accept_pressed" means that the player wants to interact with a cell. Depending
	# on the board's current state, this interaction means either that we want to select a unit all
	# that we want to give it a move order.
	print("active unit", _active_unit)
	if not _active_unit:
		_select_active_unit(cell)
	elif _active_unit.isSelected:
		print("is_occupied(cell) = ", is_occupied(cell))
		if is_occupied(cell) && _units[cell] != _active_unit:
			print('selecting target', _units[cell])
			_select_target_unit(cell)
			return
		if _active_unit.cell != cell:
			print("_active_unit.cell", _active_unit.cell)
			print("cell", cell)
			print("CELL IS NOT ACTIVE UNIT")
			_move_active_unit(cell)

func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_deselect_active_unit()
		_clear_active_unit()


func _on_unit_base_updated():
	_reinitialize()
