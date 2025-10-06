extends Node2D
var data: RoomData
@export var dimensions  : Vector2i = Vector2i(50,75)
@export var start : Vector2i = Vector2i(int(dimensions.x/2),int(dimensions.y/2))
@export var critical_path_length : int = 100
@export var min_length : int = 10 #critical path min distance from spawn
@export var branches : int = 50
@export var branch_length : Vector2i = Vector2i(2,6)
var dungeon: Array
var branch_candidates: Array[Vector2i]


var base_tile = 9 #row of the tileset to use

@export var spawn_candidates: Array[Vector2i]
@export var spawns : int = 15

const slime = preload("res://Scenes/Slime.tscn")

@onready var tile_map_layer: TileMapLayer = $tilemap/TileMapLayer


#TODO Add doors! lockable and making sure our rooms know their reward

#TODO update dungeon generation, making specific rooms (rectangular areas)
# each with their own enemy count that goes toward total

func _ready():
	#pass
	load_room()

func load_room():
	print("Placing tile")
	_initialize_dungeon()
	_place_entrance()
	#_generate_path(start, critical_path_length, "C")
	#_generate_branches()
	_generate_room(start, Vector2i(randi_range(5,10),randi_range(15,20)))
	_generate_spawns()
	_fill_gaps()
	_print_dungeon()

func _initialize_dungeon():
	for x in dimensions.x:
		dungeon.append([])
		for y in dimensions.y:
			dungeon[x].append(0)

func _place_entrance():
	
	#Random Start position, if out of range start location set, else leave it as is.
	if start.x < 0 or start.x >= dimensions.x:
		start.x = randi_range(0,dimensions.x - 1)
	if start.y < 0 or start.y >= dimensions.y:
		start.y = randi_range(0,dimensions.y - 1)
	dungeon[start.x][start.y] = "S"


#to be called with a start tile, and a size with 1/2 width and 1/1 height
#want start to be in the bottom middle (x in the center), y at bottom
func _generate_room(start: Vector2i, size: Vector2i):
	var coords_min : Vector2i = Vector2i(start.x-size.x, start.y)
	var coords_max : Vector2i = Vector2i(start.x+size.x, start.y + size.y)
	if coords_min.x < 0:
		coords_min.x = 0
	if coords_max.x >= dimensions.x:
		coords_max.x = dimensions.x-1
	if coords_min.y < 0:
		coords_min.y = 0
	if coords_max.y >= dimensions.y:
		coords_max.y = dimensions.y-1
	#all coords are legal dungeon coordinates now
	#time to put them all into the dungeon :)
	for x in range(coords_min.x,coords_max.x):
		for y in range(coords_min.y,coords_max.y):
			if !dungeon[x][y]:
				dungeon[x][y] = "R"
	
func  _generate_path(from: Vector2i, length:int, marker: String) -> bool:
	if length == 0:
		if marker == "C":
			if from.distance_to(start) < min_length:
				return false
		return true
	var current : Vector2i = from            
	var direction : Vector2i
	match randi_range(0,3):
		0:
			direction = Vector2i.UP
		1:
			direction = Vector2i.RIGHT
		2:
			direction = Vector2i.LEFT
		3:
			direction = Vector2i.DOWN
	for i in 4:
		if (current.x + direction.x >= 0 and current.x + direction.x < dimensions.x and 
			current.y + direction.y >= 0 and current.y + direction.y < dimensions.y and
			not dungeon[current.x+direction.x][current.y+direction.y]):
			current += direction
			dungeon[current.x][current.y] = marker
			if length >1:
				branch_candidates.append(current)
				if start.distance_to(current) > 5:
					spawn_candidates.append(current)
				
			if _generate_path(current, length-1, marker):
				return true
			else:
				branch_candidates.erase(current) 
				dungeon[current.x][current.y] = 0
				current -= direction
		direction = Vector2(direction.y,-direction.x)
	return false


func _generate_branches():
	var branches_created : int = 0
	var candidate : Vector2i
	while branches_created < branches and branch_candidates.size():
		candidate = branch_candidates[randi_range(0, branch_candidates.size() - 1)]
		if _generate_path(candidate, randi_range(branch_length.x, branch_length.y), "D"):
			branches_created += 1
		else:
			branch_candidates.erase(candidate)

func _generate_spawns():
	var spawns_created : int = 0
	var spawn : Vector2i
	while spawns_created < spawns and spawn_candidates.size():
		spawn = spawn_candidates[randi_range(0, spawn_candidates.size() - 1)]
		spawns_created += 1
		spawn_enemy(spawn)

func spawn_enemy(location: Vector2i):
	#TODO add a system where you spawn a mob and based off of the type spawned, it removes points from spawns corellating to its difficulty
	
	dungeon[location.x][location.y] = "E"
	
	tile_map_layer.to_global(location)
	
	

func pick_enemy():
	#TODO : select an enemy that is within the budget to spawn
	
	#set slime to be budget of 1
	if spawns >= 1:
		spawns -= 1
		return preload("res://Scenes/Slime.tscn")

func _fill_gaps():
	#TODO This shit inefficent as fuck!!!
	#first pass
	for x in range(1,dimensions.x-1): #s.t. we dont break bounds
		for y in range(1,dimensions.y-1):#s.t. we dont break bounds
			#if 3 of the neighbouring tiles are solid, make it solid
			if(!dungeon[x][y]):
				if  (dungeon[x][y+1] and dungeon[x][y-1] and dungeon[x+1][y] or
					dungeon[x][y+1] and dungeon[x][y-1] and dungeon[x-1][y] or
					dungeon[x+1][y] and dungeon[x-1][y] and dungeon[x][y+1] or
					dungeon[x+1][y] and dungeon[x-1][y] and dungeon[x][y-1]):
					dungeon[x][y] = "f"
	#second pass :)
	for x in range(1,dimensions.x-1): #s.t. we dont break bounds
		for y in range(1,dimensions.y-1):#s.t. we dont break bounds
			#if 3 of the neighbouring tiles are solid, make it solid
			if(!dungeon[x][y]):
				if  (dungeon[x][y+1] and dungeon[x][y-1] and dungeon[x+1][y] or
					dungeon[x][y+1] and dungeon[x][y-1] and dungeon[x-1][y] or
					dungeon[x+1][y] and dungeon[x-1][y] and dungeon[x][y+1] or
					dungeon[x+1][y] and dungeon[x-1][y] and dungeon[x][y-1]):
					dungeon[x][y] = "f"

func _print_dungeon() -> void:
	var dungeon_as_string = ""
	for y in range(dimensions.y -1, -1, -1):
		for x in dimensions.x:
			if dungeon[x][y]:
				var tile_position = Vector2i(x,y)
				dungeon_as_string += "[" +str(dungeon[x][y]) + "]"
				_tile_placer(tile_position)
			else: dungeon_as_string +="[ ]"
		dungeon_as_string += '\n'
	print(dungeon_as_string)

func _tile_placer(tile_position):
	if tile_map_layer == null:
		print("AHHHHHHHHHHHHHHHHHH!")
		push_error("Tilemap not initialized yet!")
		return
	print("adding a tile")
	var marker = dungeon[tile_position.x][tile_position.y]
	match marker:
		"S": #start
			tile_map_layer.set_cell(tile_position,2,Vector2i(1,base_tile))
			$Player.position = tile_map_layer.map_to_local(tile_position)
			print("Player position: ", $Player.position)
		0:  #nothing
			pass
		"R": #Room
			tile_map_layer.set_cell(tile_position,2,Vector2i(0,base_tile))
		"E": #enemy
			tile_map_layer.set_cell(tile_position,2,Vector2i(2,base_tile))
			#spawn enemy
			var Slime = slime.instantiate()
			add_child(Slime)
			Slime.initialize(tile_map_layer.map_to_local(tile_position))
			print("Slime spawned!")
		_: #default
			tile_map_layer.set_cell(tile_position,2,Vector2i(0,base_tile))

func setup(room_data: RoomData):
	data = room_data
	lock_doors()
	var difficulty = (data.depth + 1) * 2 
	#ProceduralSpawner.spawn_enemies(difficulty, enemy_container)
	#TODO

func lock_doors():
	pass

#TODO : unlock all the doors, other than where you came from (as it collapsed)
func unlock_doors():
	pass

func _on_enemy_died():
	if $EnemyContainer.get_child_count() == 0:
		unlock_doors()
		spawn_reward()

func spawn_reward():
	#spawn the reward for the player.
	pass #TODO
