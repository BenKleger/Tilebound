extends CharacterBody2D

#Constants
const speed = 20
const dash_speed = 500
const max_health = 100

#variables
var dash_not_active = true
var shoot_ready = true
var damage_ready = true
var ground_coefficent = 10
var air_coefficent = 7
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

func _ready():
	call_deferred("spawn_grappling_hook")

func spawn_grappling_hook():
	print("\n=== Spawning grappling hook ===")

	var HookScene = preload("res://Scenes/grappling_hook.tscn")
	var hook_instance = HookScene.instantiate()

	if hook_instance == null:
		print("❌ Instantiation failed!")
		return

	hook = hook_instance

	# Add a red box to ensure visibility

	hook.global_position = Vector2(400, 300)  # hardcoded center
	hook.rotation = (get_global_mouse_position() - global_position).angle()
	hook.player = self

	# Try both adding methods to guarantee it's in the tree
	#add_child(hook)  # safest method if inside player
	get_parent().add_child(hook)  # use this ONLY if needed

	await get_tree().process_frame  # allow tree to update

	print("hook: ", hook)
	print("hook.get_parent(): ", hook.get_parent())
	print("hook.is_inside_tree(): ", hook.is_inside_tree())
	print("hook global_position: ", hook.global_position)

	if hook.get_child_count() > 0:
		print("✅ Hook has visible child!")
	else:
		print("❌ Hook has no children (invisible?)")

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
	
	#update position for enemy tracking
	if ! in_air:
		last_position_on_ground = global_position
		
	if velocity != Vector2.ZERO:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")

#TODO Bounce Pad
#TODO Summoning
#TODO Fix grappling hook
#TODO Fix size speed issue


func falling_check():
	pass
	#if(in_air):
		#pass
	#else:
	 ##check for if there is a tile below the player and if there isn't begin falling
		#if(Input.is_action_pressed("ui_accept")):
			#fall()

func instantiate():
	pass

func fall():
	in_air = true
	$AnimationPlayer.play("falling")
	$FallingTimer.start()

func take_damage(damage: int):
	if (health-damage<=0):
		health = 0
		print("Player has died")
		kill()
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

func movement_direction_calculator():
		var direction: Vector2 = Vector2.ZERO; 
	##********
	#var player_is_paused = false;
	#if(player_is_paused):
		#velocity.x = 0;
		#velocity.y = 0;
		##is this even necesarry? tbd :)
	##x velocity calculation
	#else:
		if(Input.is_action_pressed("ui_left")):
			if(Input.is_action_pressed("ui_right")):
				direction.x = 0;
			else:
				direction.x = -1.865;      
				
		else:
		#2
			if(Input.is_action_pressed("ui_right")):
				direction.x = 1.865;
			else:
				direction.x = 0;
		#Y direction calculation
		if(Input.is_action_pressed("ui_up")):
			direction.y = -1;
			if(Input.is_action_pressed("ui_down")):
				direction.y = 0 
		else:
			if(Input.is_action_pressed("ui_down")):
				direction.y = 1;
			else:
				direction.y = 0;
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
	if dash_not_active:
		if in_air:
			velocity.x = input.x * speed * air_coefficent
			velocity.y = input.y * speed * air_coefficent
		else:
			velocity.x = input.x * speed * ground_coefficent
			velocity.y = input.y * speed * ground_coefficent
	else:
		#dash is active
		pass #keep velocity constant

	##Horizontal movement code
	##if player is on the ground, there is friction and movement speed is reduced by a modifier
	#input.x = input.x * delta * speed * input_coefficient
	#input.y = input.y * delta * speed * input_coefficient
	#if !in_air:
		##X stuff
		#
		#if velocity.x > 0:
			#velocity.x = floor(input.x * input_coefficient + velocity.x * friction_modifier)
		#else:
			#velocity.x = ceil(input.x * input_coefficient + velocity.x * friction_modifier)
		##Y stuff
		#if velocity.y > 0:
			#velocity.y = floor(input.y * input_coefficient + velocity.y * friction_modifier)
		#else:
			#velocity.y = ceil(input.y * input_coefficient + velocity.y * friction_modifier)
	#else:
		#velocity.x = velocity.x + floor(input.x)*.5
		#velocity.y = velocity.y + floor(input.y)*.5

func input_reader():
	if(Input.is_action_pressed("jump")): 
		jump();
	if(Input.is_action_pressed("dash")):
		dash();
	if(Input.is_action_pressed("grapple")):
		grapple_throw()
	if(Input.is_action_pressed("shoot")):
		shoot()

func jump():
	if(jump_ready):
		$AnimationPlayer.play("jump!")
		jump_ready = false
		in_air = true;
		last_position_on_ground = global_position
		$JumpTimer1.start() #collision box disappears
		$JumpTimer2.start() #collision box reappaears
		$JumpTimer3.start() #landing
		$JumpTimer4.start() #ready to jump again
	#***** TODO, set up invulnerability stuff here when thats added :)
		$PlayerBody.set_deferred("disabled", true);

func dash():
	if (dash_ready == true):
		dash_ready = false
		dash_not_active = false
		$DashCD.start()
		$DashActiveTimer.start()
		velocity = dash_speed * last_input
		velocity = dash_speed * last_input

func shoot():
	print("shoot sent")
	if(shoot_ready):
		var bullet = preload("res://Scenes/Projectile.tscn").instantiate()
		bullet.position = global_position
		bullet.direction = get_global_mouse_position()-global_position
		bullet.init_velocity = velocity
		bullet.damage = 5
		bullet.player_projectile = true
		#bullet.sprite_texture = preload("res://assets/bullet.png")
		get_tree().current_scene.add_child(bullet)
		shoot_ready = false
		
		$ShootTimer.start()

func grapple_throw():
	##TODO Grappling hook --> BRINGS MOBS to the player --> maybe a stun and free crit hit type deal
	if(grapple_ready):
		#1. THROW GRAPPLING HOOK
		#send it with relative velocity towards the mouse / cursor 
		print("throw sent")
		hook.throw_init(get_global_mouse_position(), velocity)
		grapple_ready = false
		grappling = true
		#TODO Compatability -- if want it to be controller compatible will have to do some things
		#set up aiming stuff
		
		#2. START TIMER, IF grappleConnect signal is NOT sent before timer runs out, grappling hook retracts
			#if executes, retracts grappling hook, calling grapple_empty_retract()

		#3. Grapple hook DOES connect -->conducted in grapple hook signal method and grappling hook code. 
		
	
	pass



	
	#TODO set up another timer that sets grappling to false when the grapple hook returns to the player --> as is, you cant hook anyone on the return of it
			#would need to figure out how to set up an exact amount of time when the grappling hook returns
			#or could make it so the grappling hook is only 'alive' when the player sends it out, and just kill it when
			#it returns to the player, colliding with the player's hitbox...
	grappling = false


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


func _on_shoot_timer_timeout() -> void:
	shoot_ready = true
	pass # Replace with function body.


func _on_dash_active_timer_timeout() -> void:
	dash_not_active = true # Replace with function body.
	velocity = Vector2.ZERO
