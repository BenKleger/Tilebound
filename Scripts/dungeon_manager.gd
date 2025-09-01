extends Node2D

#chat



#me
var visited_rooms = []
var max_length:int = 10
var grid = []
const Room = preload("res://Scenes/room.tscn")
const ROOM_DATA = preload("res://resources/RoomData.tres")

func _ready():
	# 0. initialize grid
	initialize_grid()
	# 1. Generate dungeon graph
	generate_dungeon()
	# 2. Spawn starting room
	load_room(0)  # starting room id

func initialize_grid():
	#every entry in the 2d array contains 
	for x in range(max_length):
		print(x)
		grid.append([])
		for y in range(10):
			if(x == 0 && y >= 1): # 1 start room
				break
			if(x == max_length-1 && y >= 1): # 1 boss room
				break
			var room_data = ROOM_DATA
			room_data.id = x*10+y #setting y for loop to more than 10 iterations fucks this up
			room_data.depth = x
			room_data.type = room_data_type(x)
			var room = Room.instantiate()
			room.setup(room_data)
			grid[x].append(room)

# -------------------------
# Dungeon Graph Generation
# -------------------------
func generate_dungeon():
	var k: int = 0
	for i in grid: #row of dungeon
		k += 1
		for j in i: #room of dungeon
			if j: #room is not null --> most of start rooms and end rooms
				
				#set up links
				if k<max_length-1:# --> not end room
					for x in 3:
						j.data.children.append(grid[k][randi_range(0,9)])
						print("appending!")



func load_room(id: int):
	const GAME = preload("res://Scenes/game.tscn")
	#TODO
	var room = grid[floor(id/10)][id%10]
	add_child(room)
	await room.ready
	room.load_room()
	
	
	## Remove previous room
	#if $CurrentRoom.get_child_count() > 0:
		#$CurrentRoom.get_child(0).queue_free()
#
	#
	## Otherwise, generate a new one
	#var data: RoomData = Room.data
	#var room: Node2D
#
	#$CurrentRoom.add_child(room)
	#visited_rooms.append(room)





func room_data_type(x):
	var y = randi_range(0,10)
	match x:
		0:
			return "start"
		1,2,3,4,6,7,8:
			if y < 8: return "combat"
			else: return "shop"
		5:
			return "treasure"
		9:
			return "boss"
		_:
			return "error" #default case

func room_data_reward(type):
	match type:
		"start": return "none"
		"combat": 
			return combat_loot()
		"shop": "none"
		"boss":
			boss_loot()

func boss_loot():
	return "tbd"
			#coin, health, item, upgrade,

func combat_loot():
	return "tbd"
			#coin, health, item, upgrade,



# -------------------------
# Room Management
# -------------------------


# -------------------------
# Player moves through door
# -------------------------
func go_to_room(target_id: int):
	load_room(target_id)
