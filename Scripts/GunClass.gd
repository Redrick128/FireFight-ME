class_name GunClass

extends Node

@onready var BulletScene: PackedScene = preload("res://Scenes/BulletScene.tscn")
@export var AmmoSpawn: Node3D
@export var Bulletstorage: Node3D

var SD
var BulletWeight: float = 0.00362
var ig7 # hell_nah
var BC_ig7

func _physics_process(delta: float) -> void:
	pass

func Shoot():
	# calculating drag
	
	var Bullet = BulletScene.instantiate()
	
	
	Bulletstorage.add_child(Bullet)
	
	var SD1 = 7000 * 0.0486607
	SD = BulletWeight / SD1
	
	# 2. ig7
	
	BC_ig7 = 0.176
	ig7 = SD / BC_ig7
	
	Bullet.Bullet_Mass = BulletWeight
	Bullet.BC_ig7 = 0.176
	Bullet.SD = SD
	
	Bullet.global_position = AmmoSpawn.global_position
	Bullet.global_transform.basis = AmmoSpawn.global_transform.basis
	
	Bullet.Velocity = AmmoSpawn.global_transform.basis * Vector3(0, 0, GlobalPlayerScript.PrimaryAmmoVelocity)
