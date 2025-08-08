extends Node2D
const PROJECTILE = preload("res://Scenes/projectile.tscn")

func _ready():
	var arrow = PROJECTILE.instantiate()
	
