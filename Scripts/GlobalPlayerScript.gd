extends Node

# State Machine

## Disables or Enables Player movement. Useful for Vehicles.

@export var PlayerData = ["null_State"]
@export var PlayerMovementState : String = "is_Idle"
@export var CanMove : bool = true


# Primary Weapon Data | Has to be changed per weapon.
## The Ammo Velocity of the primary weapon im m/s. Always negative.
@export var PrimaryAmmoVelocity : int = -880 
## The Current Ammo Count of the Primary weapon.
@export var PrimaryAmmoCount : int = 30
## The Maximum Ammo Count of the Primary weapon.
@export var PrimaryAmmoCountMax : int = 30
## The Current Fire Mode of the Primary weapon
@export var PrimaryFireMode : int = 2
## The Timer of the Auto Fire Mode of the Primary Weapon. Exclusivley for Auto.
@export var PrimaryAutoTimer : float = 0
## The Value that enables the PrimaryAutoTimer.
@export var PrimaryShouldFlowTimer : bool = true
## The Weight of the Bullet of the Primary weapon in lbs.
@export var PrimaryBulletWeightLbs : float = 0.0486607
## A Value that is used as a Cooldown of the Primary Weapon. Only for Semi Fire Modes.
@export var Primary_Has_Fired	   : bool = false # Only for semi fire.
## A RayCast in the Primary weaponused to determine the distance of where the Bullet should 
## fire into for calculations. 
@export var Primary_Cast		   : RayCast3D

# 1 Is in menu 0 is out of menu
## A Value that controls the players ability to input.
@export var MenuFocus : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensures that the player can move on first launch of scene.
	PlayerData[0]="is_Idle"

func _physics_process(delta: float) -> void:
	# State Machine
	PlayerData[0]=PlayerMovementState

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if PrimaryAmmoCount != 1:
		PrimaryShouldFlowTimer = true

	if PrimaryFireMode == 2 and PrimaryShouldFlowTimer:
		PrimaryAutoTimer += delta
		#print(PrimaryAutoTimer)
	else: pass
