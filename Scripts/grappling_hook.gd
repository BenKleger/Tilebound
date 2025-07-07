extends CharacterBody2D
#mechanic for grappling where it fails and you have to fix it, or it will malfunction kinda stunning you
@export var speed = 100

var dir : float
var spawnPos : Vector2
var spawnRot: float

func _ready():
	global_position = spawnPos
	global_rotation = spawnRot

signal grappleConnect

func _on_area_2d_body_entered(body: Node2D) -> void:
	grappleConnect.emit()

func throw():
	velocity.x = 100
	velocity.y = 200
	print("Throw passed")
