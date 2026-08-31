extends Node3D

@export var gravity: float = 9.8
@export var Velocity: Vector3 = Vector3.ZERO
@export var Drag : float
@export var Cd : float
@export var Bullet_Mass : float = 0.00362
@export var Bullet_Diameter : float = 0.0056

@export var BC_ig7 : float = 0.176
@export var SD : float
@export var ig7 :float

@export var Cast : RayCast3D
@export var Is_move : bool = true

func CalcDrag(Cd: float, Density: float, Velocity: float, Area: float) -> float:
	var Drag = Cd * Density * pow(Velocity, 2) * Area
	if Drag <= 0.1:
		return 0.0
	else: return Drag

func CalciG7(M: float) -> float:
	if M >= 0.0 and M < 0.80:
		return 0.1750 + (0.015 * pow(M, 2))
	
	elif M >= 0.80 and M < 1.15:
		return 0.1846 + (0.425 * pow(M - 0.80, 2))
		
	elif M >= 1.15 and M < 1.40:
		return 0.3365 - (0.115 * (M - 1.15))
	
	elif M >= 1.40 and M < 3.50:
		return (0.182 / sqrt(pow(M, 2) - 1.0)) + 0.125
	
	elif M >= 3.50:
		return 0.179
	
	else: return 0.0

func _physics_process(delta: float) -> void:
	if Is_move == false:
		
		self.queue_free()
	
	# MATH NOTE #
	"""
	So to get our target we get the object, information about it, and its distance.
	If Time = Distance/Speed then the distance on detection divided by the speed gives
	us the flight time. We create a timer to where it would likely hit and if so do something.
	
	"""
	
	if GlobalPlayerScript.Primary_Cast.is_colliding():
		var prim_hit_obj =  GlobalPlayerScript.Primary_Cast.get_collider()
		var HitDist = self.global_position.distance_to(prim_hit_obj.global_position)
		if HitDist < 400:
			await get_tree().create_timer(HitDist/Velocity.length()*delta).timeout
			if HitDist < 50 and prim_hit_obj:
				print("Hit_Pos : " + str(prim_hit_obj.global_position) + "Hit obj : " + str(prim_hit_obj.get_class()) + "Name : " + prim_hit_obj.name)
				if prim_hit_obj.has_method("DealDamageTS"):
					prim_hit_obj.DealDamageTS(10)
				
				Is_move = false
	
	if Cast.is_colliding():
		var HitObj = Cast.get_collider()
		var HitDist = self.global_position.distance_to(HitObj.global_position)
		if HitDist < 400:
			await get_tree().create_timer(HitDist/Velocity.length()*delta).timeout
			if HitDist < 50 and HitObj:
				print("Hit_Pos : " + str(HitObj.global_position) + "Hit obj : " + str(HitObj.get_class()) + "Name : " + HitObj.name)
				
				if HitObj.has_method("DealDamageTS"):
					HitObj.DealDamageTS(10)
				
				Is_move = false
	
	ig7 = SD / BC_ig7
	
	var M = Velocity.length() / 343.0
	Cd = ig7*CalciG7(M)
	
	Drag = CalcDrag(Cd, 1.225, Velocity.length(), PI * pow(Bullet_Diameter / 2.0, 2))
	
	var Deceleration = Drag / Bullet_Mass
	
	Velocity -= Velocity.normalized() * Deceleration * delta
	
	Velocity.y -= 9.8 * delta
	
	self.global_position += Velocity * delta
	
	#self.global_position += Velocity*delta # Idk why the actual fuck this is doubled.
	
	# -- Debug ----------------------------------------------
	#print ("Drag is : ", Drag, "Speed is : ", "Mach", M)
