extends Node

@export var AmmoVelocity : int = -2
@export var AmmoCount : int = 30

@export var FireMode : int = 2

@export var AutoTimer : float = 0
@export var ShouldFlowTimer : bool = true

@export var DragForce: float

@export var Velocity : Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if AmmoCount <= 0:
		ShouldFlowTimer = false
	
	if FireMode == 2 and ShouldFlowTimer:
		AutoTimer += delta
		print(AutoTimer)
	else: pass
