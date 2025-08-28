extends Node2D

var rotation_amount
var fireballWand : CharacterBody2D
var hook : CharacterBody2D
var grapple_ready : bool
@onready var player: CharacterBody2D = get_parent()
var active_weapons = []
var shoot_ready : bool = true

func _ready():
	call_deferred("spawn_fireball_wand")
	call_deferred("spawn_grappling_hook") #max 1
	call_deferred("spawn_fireball_wand")
	call_deferred("spawn_fireball_wand")
	call_deferred("spawn_fireball_wand")
	call_deferred("spawn_fireball_wand")
	call_deferred("spawn_fireball_wand")
	call_deferred("spawn_fireball_wand")
	call_deferred("spawn_fireball_wand")
	call_deferred("spawn_fireball_wand")
	call_deferred("spawn_fireball_wand")
	call_deferred("spawn_fireball_wand")
	call_deferred("spawn_fireball_wand")
	call_deferred("spawn_fireball_wand")
	call_deferred("spawn_fireball_wand")
	call_deferred("spawn_fireball_wand")
	call_deferred("spawn_fireball_wand")
	
func _process(delta):
	var n : int = 1
	var r = 30
	var vec_r = - (global_position - get_global_mouse_position())
	var theta_a=vec_r.angle()
	for i in active_weapons:
		var angle_offset = 0.2*pow(-1,n)*floor(n/2) #Coefficent is gap angle between weapons in radians
		var theta_b = theta_a + angle_offset
		var idle_position = r*Vector2.from_angle(theta_b)
		i.rest_position = player.global_position+idle_position
		n +=1
	n=0
	#want to add a force s.t. the weapons stay slightly apart from one another,either by adding a position offset, or some velocitry
	#Lets go for something like first weapon in array goes to the neutral position, 2nd item goes 6 deg to right, 3rd item goes 6 to left, then 4th 12 to right,
	#so something like 

func spawn_grappling_hook():
	
	var HookScene = preload("res://Scenes/grappling_hook.tscn")
	hook = HookScene.instantiate()
	hook.rotation = (get_global_mouse_position() - global_position).angle()
	hook.player = player
	get_parent().get_parent().add_child(hook) 
	active_weapons.push_front(hook)

func spawn_fireball_wand():
	var fireball_wand = preload("res://Scenes/fireball_wand.tscn")
	fireballWand = fireball_wand.instantiate()
	fireballWand.rotation = (get_global_mouse_position() - global_position).angle()
	fireballWand.player = player
	get_parent().get_parent().add_child(fireballWand) 
	active_weapons.append(fireballWand)


func shoot():
	for i in active_weapons:
		if i.has_method("shoot"):
			i.shoot()

func grapple_throw():
	if(grapple_ready):
		#1. THROW GRAPPLING HOOK
		#send it with relative velocity towards the mouse / cursor 
		print("throw sent")
		hook.throw_init(get_global_mouse_position(), player.velocity)
		grapple_ready = false
		#TODO Compatability -- if want it to be controller compatible will have to do some things
		#set up aiming stuff
		
		#2. START TIMER, IF grappleConnect signal is NOT sent before timer runs out, grappling hook retracts
			#if executes, retracts grappling hook, calling grapple_empty_retract()

		#3. Grapple hook DOES connect -->conducted in grapple hook signal method and grappling hook code. 
		
	
	pass



	
	#TODO set up another timer that sets grappling to false when the grapple hook returns to the player --> as is, you cant hook anyone on the return of it
			#would need to figure out how to set up an exact amount of time when the grappling hook returns
			#or could make it so the grappling hook is only 'alive' when the player sends it out, and just kill it when
			#it returns to the player, colliding with the player's hitbox...w
