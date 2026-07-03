extends Node2D
var a :Array = [0,1,2,3,4]

const SLIME = preload("res://Scenes/Slime.tscn")

func _ready():
	for i in range(10):
		print(i)

	var slime = SLIME.instantiate()
	print("Slime Spawned at position: ", slime.position)
