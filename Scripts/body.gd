extends CharacterBody2D

#Constants
const speed = 5
const dash_speed = 250
const max_health = 100

#variables
var on_ground : Array  = [true, true, true, true, true, true, true]
var immune = false
var falling = false
var dash_not_active = true
var shoot_ready = true
var damage_ready = true
var ground_coefficent = 10
var air_coefficent = 12
var health = 100
var dead = false
var in_air = false
var jump_ready = true
var dash_ready = true
var grapple_ready = true
var grappling = false
var enemy_in_attack_range = false
var last_input:Vector2 = Vector2.DOWN;
#for enemy tracking purposes
var last_position_on_ground:Vector2 = global_position
var hook : CharacterBody2D
#@export var friction_modifier = 0.95 # was used for previous movement engine
@onready var particles := $DashParticles
@onready var ParticleMaterial := particles.process_material as ParticleProcessMaterial
@onready var player_body: CollisionShape2D = $PlayerBody
@onready var weapon_manager: Node2D = $WeaponManager
@onready var tilemap: Node2D = $"../../tilemap/TileMapLayer"

func _ready():
	hook = weapon_manager.hook
	
	print("Parent of Player is:", get_parent().get_parent().name)
	
	
func player():
	pass

func _enter_tree() :
	$AnimatedSprite2D.play("idle")
	


func _process(delta):
	get_veloc(movement_direction_calculator(), delta);
	
	input_reader()
	
	move_and_slide() 
	
	enemy_attack()
	
	falling_check()
	
	animate()

#TODO Bounce Pad --> with in air enemies add some form of retaliation --> shoot a homing projectile at them with the press of a button, using similar mechanics to the grapple return stuff to chase and scale in size properly.
#TODO Summoning



func animate():
	if velocity != Vector2.ZERO:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")

func falling_check():
	#update position for enemy tracking
	if ! in_air:
		last_position_on_ground = global_position
	
	
	# Check if standing on a platform
	#var local_pos = tilemap.to_local(global_position)  # convert to TileMapLayer space
	#var tile_pos = tilemap.local_to_map(tilemap.to_local(global_position))
	var tile_data  = tilemap.get_cell_tile_data(tilemap.local_to_map(tilemap.to_local(global_position)))
	var tile_data1 = tilemap.get_cell_tile_data(tilemap.local_to_map(tilemap.to_local(global_position + Vector2.DOWN * 15)))
	var tile_data2 = tilemap.get_cell_tile_data(tilemap.local_to_map(tilemap.to_local(global_position + Vector2.LEFT * 15)))
	var tile_data3 = tilemap.get_cell_tile_data(tilemap.local_to_map(tilemap.to_local(global_position - Vector2.LEFT * 15)))
	var tile_data4 = tilemap.get_cell_tile_data(tilemap.local_to_map(tilemap.to_local(global_position - Vector2.DOWN * 15)))
	
	var on_platform = tile_data != null or tile_data1 != null or tile_data2 != null or tile_data3 != null or tile_data4 != null 
	#iterate thru all neighbouring tiles, if the player is on one of them, he's also safe from falling
	
	
	
	#coyote time stuff
	#want to check if the player is on the platform, put that in the 0th index of fall_check,
	#but first move 0->1, 1->2, 2->3, 3->4
	
	if !in_air && dash_not_active:
		for i in range(len(on_ground)-2,-1,-1):
			on_ground[i+1] = on_ground[i]
			 
		on_ground[0] = on_platform
		
		if !on_ground_check():
			if !falling:
				fall()
	
	
	

func on_ground_check():
	for i in on_ground:
		if i == true:
			return true
	return false
	


func fall():
	falling = true
	print("FALLING!")
	$AnimationPlayer.play("falling")
	$FallingTimer.start()

func take_damage(damage: int):
	if !immune:
		if (health-damage<=0):
			health = 0
			print("Player has died")
			kill()
		elif (health - damage > max_health):
			health = max_health
		else:
			health -= damage;
			print("ENEMY HAS ATTACKeD! Health is now: ", health)
			#start damage timer
			damage_ready = false
			$DamageTimer.start()
		
#old script
#would take negative damage to heal sucessfully
	#if damage > 0: #taking damage
		#if damage < health:
			#health -= damage;
		#else:
			#health = 0;
			#kill()
	#else: 	 	#healing --> negative damage
		#if health-damage <= max_health:
			#health -= damage
		#else: 
			#health = max_health

func kill():
#	self.queue.free()
	pass
	dead = true;
	health = 0;
	print("DEAD!!!!")
	
	#TODO add a fade to black first
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func movement_direction_calculator():
		var direction: Vector2 = Vector2.ZERO; 
	#stupid ahh fix for stupid ahh tiles
	#var player_is_paused = false;
	#if(player_is_paused):
		#velocity.x = 0;
		#velocity.y = 0;
		##is this even necesarry? tbd :)
	##x velocity calculation
	#else:
		if(Input.is_action_pressed("ui_left")):
			if(!Input.is_action_pressed("ui_right")):
				direction.x = -1.865;      
				
		else:
			if(Input.is_action_pressed("ui_right")):
				direction.x = 1.865;
		#Y direction calculation
		if(Input.is_action_pressed("ui_up")):
			if(!Input.is_action_pressed("ui_down")):
				direction.y = -1;
		else:
			if(Input.is_action_pressed("ui_down")):
				direction.y = 1;
		#normalization   
		#for normalization, as the map is (currently) a 16x32 setup, it would be nice if we moved 16 pixels up for every 32 horizontal while both are pressed.
		#this would result in twice as much horizontal motion as vertical... can just update direction.x to 2 instead of 1 in all the lines above, and normalize it the same way :)
		direction = direction.normalized();



		#setting last input if it is non-zero
		if(direction.length() != 0):
			last_input = direction;
		return direction

func get_veloc(input: Vector2, delta) -> void:
	
	#all this stuff was mostly just from the previous game, want to make it more responsive movement, give some 'friction' in air keeping some velocity, not being perfectly responsive... unless?? just slowed down?
	#if dash_not_active:
		#if in_air:
			#velocity.x = input.x * speed * air_coefficent
			#velocity.y = input.y * speed * air_coefficent
		#else:
			#velocity.x = input.x * speed * ground_coefficent
			#velocity.y = input.y * speed * ground_coefficent
		#
	#
		##dash is active
	#else:
		#pass #keep velocity constant

	#Horizontal movement code
	#if player is on the ground, there is friction and movement speed is reduced by a modifier
	if dash_not_active:
		input = input * speed
		var friction_modifier = .1
		if !in_air:
			#X stuff
			if velocity.x > 0:
				velocity.x = floor(input.x * ground_coefficent + velocity.x * friction_modifier)
			else:
				velocity.x = ceil(input.x * ground_coefficent  + velocity.x * friction_modifier)
			#Y stuff
			if velocity.y > 0:
				velocity.y = floor(input.y * ground_coefficent  + velocity.y * friction_modifier)
			else:
				velocity.y = ceil(input.y * ground_coefficent + velocity.y * friction_modifier)
				
		else:
			velocity.x = velocity.x * friction_modifier * .5 + floor(input.x * air_coefficent) 
			velocity.y = velocity.y * friction_modifier * .5 + floor(input.y * air_coefficent)



func input_reader():
	if !falling:
		if(Input.is_action_pressed("jump")): 
			jump();
		if(Input.is_action_pressed("dash")):
			dash();
		if(Input.is_action_pressed("grapple")):
			grapple_throw()
		if(Input.is_action_pressed("shoot")):
			shoot()
	else: 
		velocity = Vector2.ZERO


func jump():
	#TODO add special particles for when the player jumps mid-air (not directly on platform)
	#TODO, set it up with less fuckin timers lmao
	if(jump_ready):
		$AnimationPlayer.play("jump!")
		jump_ready = false
		in_air = true;
		last_position_on_ground = global_position
		$JumpTimer1.start() #collision box disappears
		$JumpTimer2.start() #collision box reappaears
		$JumpTimer3.start() #landing
		$JumpTimer4.start() #ready to jump again
	#***** TO-DO(NE?), set up invulnerability stuff here when thats added :) --> set deffered kinda does it
		$PlayerBody.set_deferred("disabled", true);

func dash():
	if (dash_ready == true):
		immune = true
		player_body.disabled = true
		dash_ready = false
		dash_not_active = false
		$DashCD.start()
		$DashActiveTimer.start()
		velocity = dash_speed * last_input
		velocity = dash_speed * last_input
		dash_effects()

func dash_effects():
	var angle = rad_to_deg(last_input.angle())
	##fucking dumb ass fix for the cursed issue with rotation
	if(velocity.y != 0 && velocity.x != 0):
		# Diagonal — use actual angle
		angle = -angle +90
		ParticleMaterial.angle_min = angle - 5
		ParticleMaterial.angle_max = angle + 5
	else:
		# Cardinal — offset 90° to align visuals
		ParticleMaterial.angle_min = angle + 85
		ParticleMaterial.angle_max = angle + 95
	particles.restart()
	$DashParticles.emitting = true
#
 
func shoot():
	weapon_manager.shoot()

func grapple_throw():
	if(grapple_ready):
		weapon_manager.hook.throw_init(get_global_mouse_position(), velocity)
		grapple_ready = false
		grappling = true
		#TODO Compatability -- if want it to be controller compatible will have to do some things
		#set up aiming stuff
		
		#2. START TIMER, IF grappleConnect signal is NOT sent before timer runs out, grappling hook retracts
			#if executes, retracts grappling hook, calling grapple_empty_retract()

		#3. Grapple hook DOES connect -->conducted in grapple hook signal method and grappling hook code. 
		


func _on_jump_timer_timeout() -> void:
	$PlayerBody.set_deferred("disabled", true)

func _on_jump_timer_2_timeout() -> void:
	$PlayerBody.set_deferred("disabled", false)

func _on_landing_timer_timeout() -> void:
	in_air = false


func jump_ready_timeout() -> void:
	jump_ready = true


func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_attack_range = true
		if(!body.stunned):
			#attack player if not 
			pass

func _on_dash_cd_timeout() -> void:
	dash_ready = true # Replace with function body.

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_attack_range = false
		
func enemy_attack(damage = 10):
	#poor way of taking damage, want to be able to check if the enemy is stunned
	if enemy_in_attack_range:
		if damage_ready: 
			
			take_damage(damage)

func _on_falling_timer_timeout() -> void:
	kill()


func _on_damage_timer_timeout() -> void:
	damage_ready = true # Replace with function body.




func _on_dash_active_timer_timeout() -> void:
	immune = false
	player_body.disabled = false
	dash_not_active = true # Replace with function body.
	velocity = Vector2.ZERO
