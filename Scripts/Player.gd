class_name Player # ahh yes rewrite because i want my own story. April 10 2026 Redrick.

extends CharacterBody3D

@export_category("Input And Movement")
var speed
const WALK_SPEED = 4.0
const SPRINT_SPEED = 6.0
const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.004

#bob variables
const BOB_FREQ = 1.4
const BOB_AMP = 0.05
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

var p_Is_mouse_visible : bool = false

@onready var head = $Head
@onready var camera = $Head/Camera3D
@export var gun : Node3D
@export var CollisionShape : CollisionShape3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

@export_category("UI")
@export var TEMP_FPS_LABEL 		  : Label
@export var AMMO_LABEL     		  : Label
@export var TEMP_BLOOD_AMMO_LABEL : Label

# health
@export_category("health")
@export var PlayerBloodAmount : float = 5.7 # In liters yes its weird.
@export var is_bleeding = 		false

@export_category("Gun")
# gunz
@export var AmmoSpawn : 	Node3D
@export var BulletStorage : Node3D
const BULLET_SCENE = ""
@export var AmmoCount : 	int = 5
@export var MaxAmmoCount :  int
@export var HandSlot : 		int = 0

@export_category("Melee")
# Melee
@export var MeleeWeapon : 	Node3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion and not p_Is_mouse_visible:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta):
	# Rendering 2D
	#-----------------------------------------#
	var FPS = Engine.get_frames_per_second()
	TEMP_FPS_LABEL.text = "FPS : " + str(FPS)
	
	TEMP_BLOOD_AMMO_LABEL.text = "BLOOD : " + str(PlayerBloodAmount)
	
	AMMO_LABEL.text = "Ammo : " + str(AmmoCount) + "/5"
	
	#------------------------------------------#
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("Space") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle Sprint.
	if Input.is_action_pressed("Shift"):
		speed = SPRINT_SPEED
		if Input.is_action_just_pressed("S") and speed == SPRINT_SPEED:
			print("tripped") # wil make next year - Redrick 11/29/2025 # Pagod ko next year naman - Redrick 1/19/2026
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("A", "D", "W", "S")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	
	## FOV
	#var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	#var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	#camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()
	
	
	if Input.is_action_just_pressed("Escape"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("1"):
		p_Is_mouse_visible = !p_Is_mouse_visible  # flip the boolean
		Input.set_mouse_mode(
			Input.MOUSE_MODE_VISIBLE if p_Is_mouse_visible else Input.MOUSE_MODE_CAPTURED)
	# Pain incoming
	# DA Health And player punishment system
	# March 1 2026 - great now i have to make HEALTH
	## How much blood does the player have in their body. Yes its needed.
	
	if is_bleeding:
		PlayerBloodAmount = PlayerBloodAmount - 0.06 * delta
	
## BUFFER OF DOOOOM ##

var has_shot = false
var mode_is = 2

func Shoot():
	pass

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

var cooldown = false  # script-level variable
var reload_cooldown = false
