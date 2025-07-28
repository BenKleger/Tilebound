
# fireball.gd
extends "res://Scripts/projectile.gd"

func _on_area_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
