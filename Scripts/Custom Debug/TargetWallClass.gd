class_name TargetWall

"
A realy dumb class designed to test damage.
"

extends StaticBody3D

@export var Health : float = 100
@export var Thickness : float = 0
@export var ObjectMaterial : String

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Health <= 0:
		self.get_parent().queue_free()

func DealDamageTS(amount: float):
	Health = Health-amount
	print("OUCH im at : " + str(Health))
