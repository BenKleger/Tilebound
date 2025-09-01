extends Node2D
var a :Array = [0,1,2,3,4]

func _ready():
	for i in len(a)-1:
		print(a[i])
