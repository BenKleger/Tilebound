class_name FireballProjData
extends projData

const ORB_DISSIPATE___0001 = preload("res://assets/fireball/orb_dissipate___0001.png")

func new():
	speed = 400.0
	damage = 5
	sprite_texture = ORB_DISSIPATE___0001
	duration= 1
	angular_velocity = 100
