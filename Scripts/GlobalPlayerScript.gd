extends Node

@export var PrimaryAmmoVelocity : int = -880 
@export var PrimaryAmmoCount : int = 30
@export var PrimaryFireMode : int = 2
@export var PrimaryAutoTimer : float = 0
@export var PrimaryShouldFlowTimer : bool = true
@export var PrimaryBulletWeightLbs : float = 0.0486607
@export var Primary_Has_Fired	   : bool = false # Only for semi fire.

@export var Primary_Cast		   : RayCast3D

# 1 Is in menu 0 is out of menu
@export var MenuFocus : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if PrimaryAmmoCount <= 0:
		PrimaryShouldFlowTimer = false

	if PrimaryFireMode == 1 and PrimaryShouldFlowTimer:
		PrimaryShouldFlowTimer = false
	elif PrimaryFireMode == 1 and !PrimaryShouldFlowTimer:
		PrimaryShouldFlowTimer = true

	if PrimaryFireMode == 2 and PrimaryShouldFlowTimer:
		PrimaryAutoTimer += delta
		#print(PrimaryAutoTimer)
	else: pass
