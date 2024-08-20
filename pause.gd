extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = not get_tree().paused
		self.visible = get_tree().paused
		print (get_tree().paused)
