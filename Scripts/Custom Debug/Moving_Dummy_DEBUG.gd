extends MeshInstance3D

var time:float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time+= delta
	self.position.x = sin(time * 5) * 7
