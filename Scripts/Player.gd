"""
MIT License

Copyright (c) 2023 LegionGames

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Modifications Copyright (c) 2026 Bitz (Redrick128)
ALl modifications are sublicensed under CC BY 4.0.

Summary of changes made by Bitz (Redrick128)

- Integration of a State machine.
- Integration with Game mechanics such as weapons.

"""

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

@export var CollisionShape : CollisionShape3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

@export_category("UI")
@export var PrimaryAmmoCurve : Curve
@export var TEMP_FPS_LABEL 		  : Label
@export var AMMO_LABEL     		  : Label
@export var FIRE_MODE      		  : Label
@export var TEMP_BLOOD_AMMO_LABEL : Label
@export var TEMP_AUTO_TIMER		  : Label

# health
@export_category("health")
@export var PlayerBloodAmount : float = 5.7 # In liters yes its weird.
@export var bleeding_rate : float = 0.06
@export var is_bleeding   : bool = false

@export_category("Gun")
# gunz
@export var GunObj : GunClass
@export var SemiTimer : Timer

@export_category("Animation")
@export var AnimPlayer: AnimationPlayer

func _ready():
	
	Engine.max_fps = 200
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	GlobalPlayerScript.Primary_Cast = $"Head/Camera3D/R_Hand/PrimaryWeapon/PrimaryCast"

func _input(event: InputEvent) -> void:
	if GlobalPlayerScript.MenuFocus == 0:
		pass
	
	if Input.is_action_pressed("LMB") and GlobalPlayerScript.PrimaryFireMode == 1 and GlobalPlayerScript.Primary_Has_Fired == false and GlobalPlayerScript.PrimaryAmmoCount > 0:
		GunObj.Shoot()
		GlobalPlayerScript.Primary_Has_Fired = true
		GlobalPlayerScript.PrimaryAmmoCount = GlobalPlayerScript.PrimaryAmmoCount - 1
	if Input.is_action_just_released("LMB") and GlobalPlayerScript.PrimaryFireMode == 1 and GlobalPlayerScript.Primary_Has_Fired == true:
		SemiTimer.start()
		await SemiTimer
		GlobalPlayerScript.Primary_Has_Fired = false
		
		if GlobalPlayerScript.PrimaryFireMode == 2:
			SemiTimer.stop()
		SemiTimer.stop()
	
	if Input.is_action_just_pressed("RMB"):
		AnimPlayer.play("Aim_Down_Sight_AKS74")
	elif Input.is_action_just_released("RMB"):
		AnimPlayer.play_backwards("Aim_Down_Sight_AKS74")
	
	if Input.is_action_just_pressed("Escape"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("Reload"):
		GlobalPlayerScript.PrimaryAmmoCount = GlobalPlayerScript.PrimaryAmmoCountMax
		await get_tree().create_timer(4).timeout
	
	if Input.is_action_just_pressed("Switch Fire Mode"):
		if GlobalPlayerScript.PrimaryFireMode > 0 and GlobalPlayerScript.PrimaryFireMode == 2:
			GlobalPlayerScript.PrimaryFireMode = 1
		elif GlobalPlayerScript.PrimaryFireMode > 0 and GlobalPlayerScript.PrimaryFireMode == 1:
			GlobalPlayerScript.PrimaryFireMode = 2
		else:
			print(error_string(30) + " : DUUDE THE FIRE MODE GOT FUCKED UP HARD")
		
		print(GlobalPlayerScript.PrimaryFireMode)
	
	if Input.is_action_just_pressed("1"):
		if GlobalPlayerScript.MenuFocus == 0:
			GlobalPlayerScript.MenuFocus = 1
		else: GlobalPlayerScript.MenuFocus = 0

func _unhandled_input(event):
	if event is InputEventMouseMotion and not p_Is_mouse_visible:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta):
	# Funny
	#Engine.max_fps = GlobalPlayerScript.PrimaryAmmoCount
	
	
	# Rendering 2D
	#-----------------------------------------#
	var FPS = Engine.get_frames_per_second()
	TEMP_FPS_LABEL.text = "FPS : " + str(FPS) + "/" + str(Engine.max_fps)
	
	TEMP_BLOOD_AMMO_LABEL.text = "BLOOD : " + str(PlayerBloodAmount)
	
	
	AMMO_LABEL.text = str(GlobalPlayerScript.PrimaryAmmoCount)
	
	var AmmoDiff = float(GlobalPlayerScript.PrimaryAmmoCount)/float(GlobalPlayerScript.PrimaryAmmoCountMax)

	if GlobalPlayerScript.PrimaryAmmoCount <= 0:
		AMMO_LABEL.label_settings.font_color = Color.RED.lerp(Color.BLACK, float(sin(Time.get_ticks_msec() * 1.0 * 0.5 *delta)*0.75))
	else:
		AMMO_LABEL.label_settings.font_color = Color.RED.lerp(Color.WHITE, PrimaryAmmoCurve.sample(AmmoDiff))
	
	#-- FIRE MODE CODE ------------------------#
	
	var FM : String = "ERR: NULL STR"
	
	if GlobalPlayerScript.PrimaryFireMode == 1:
		FM = "Semi"
	elif GlobalPlayerScript.PrimaryFireMode == 2:
		FM = "Auto"
	
	FIRE_MODE.text = str(FM)
	
	#------------------------------------------#
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if GlobalPlayerScript.MenuFocus == 0:


		if Input.is_action_pressed("LMB") and GlobalPlayerScript.PrimaryFireMode == 2 and GlobalPlayerScript.PrimaryAmmoCount > 0:
			if GlobalPlayerScript.PrimaryAutoTimer >= 0.092:
				GunObj.Shoot()
				GlobalPlayerScript.PrimaryAmmoCount = GlobalPlayerScript.PrimaryAmmoCount - 1
				GlobalPlayerScript.PrimaryAutoTimer = 0

		# Handle Jump.
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		# Handle Sprint.
		if Input.is_action_pressed("Run"):
			speed = SPRINT_SPEED
			if Input.is_action_just_pressed("Back Movement") and speed == SPRINT_SPEED:
				print("tripped") # wil make next year - Redrick 11/29/2025 # Pagod ko next year naman - 
								 # Redrick 1/19/2026 # Tamad at Pagod pa ko - Redrick 7/5/2026
		else:
			speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("Left Movement", "Right Movement", "Forward Movement", "Back Movement")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor() and GlobalPlayerScript.MenuFocus == 0:
		if direction:
			if speed == WALK_SPEED:
				GlobalPlayerScript.PlayerMovementState="is_Walking"
			elif speed == SPRINT_SPEED: GlobalPlayerScript.PlayerMovementState="is_Running"
			else: GlobalPlayerScript.PlayerMovementState="is_Idle"
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			GlobalPlayerScript.PlayerMovementState="is_Idle"
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	elif GlobalPlayerScript.MenuFocus == 0:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	
	## FOV
	#var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	#var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	#camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	if GlobalPlayerScript.PlayerData[0] != "null_State":
		move_and_slide()
	
	# Pain incoming
	# DA Health And player punishment system
	# March 1 2026 - great now i have to make HEALTH
	## How much blood does the player have in their body. Yes its needed.
	
	# July 5 2026 - So im gonna leave this for 5 more years because
	# Guns dont even do much yet and i want to finnish those first.
	# And also because im lazy and researching anatomy is boring.
	
	if is_bleeding and bleeding_rate > 0.0:
		PlayerBloodAmount = PlayerBloodAmount - bleeding_rate * delta
	
## BUFFER OF DOOOOM ##

# Modular gun logic



func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
