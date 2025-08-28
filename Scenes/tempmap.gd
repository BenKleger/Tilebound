extends Node2D
@onready var ground: TileMapLayer = $Stage1/Ground



func _ready():
	for x in 10:
		for y in 10:
			ground.set_cell(Vector2i(x,y),0, Vector2(2,2))
