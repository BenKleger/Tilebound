extends CharacterBody2D 
#update
var update_interval := 15
var update_offset := 0
var current_velocity := Vector2.ZERO

#idle
var idle_timer := 0.0
var idle_move_duration := 1.0
var idle_wait_duration := 5.0
var idle_moving := false
var idle_direction := Vector2.ZERO  # store the random idle direction
var idle_target_position := Vector2.ZERO

#misc vars
var player_size = 20
var speed = 50
var player_chase = false
var player = null
var radius = 0
var last_position_detected:Vector2 = Vector2.ZERO
var is_moving_to_last_position := false
var health = 100
var stunned = false

func _ready():
	update_offset = randi() % update_interval
	randomize()  # optional, in one global place
	var shape = $detection_area/CollisionShape2D.shape
	if shape is CircleShape2D:
		radius = shape.radius

func _physics_process(delta): #probably want this to run only every 30 frames or so to save processing, and have each slime run on a different frame so it isnt jittery
	var frame = Engine.get_physics_frames()
	if !stunned:
		if (frame + update_offset) % update_interval == 0:


			if player_chase:
				last_position_detected = player.last_position_on_ground
				if global_position.distance_to(last_position_detected) > player_size:
					move(last_position_detected, delta, 0.75)
				else:
					idle(delta)
			elif player != null:
				var dist = global_position.distance_to(last_position_detected)
				if (dist < radius + 20) and (dist > 5):
					move(last_position_detected, delta)
					is_moving_to_last_position = true
				else:
					is_moving_to_last_position = false
					idle(delta)
			else: 
				idle(delta)
				
			
		velocity = current_velocity
		move_and_slide()
	else:
		#stunned
		velocity = Vector2.ZERO

func move(pos:Vector2, delta, modifier = 1):

		current_velocity = (pos - global_position).normalized() * speed * modifier
		$AnimatedSprite2D.play("walk")
		if (pos.x-global_position.x)<0:
			$AnimatedSprite2D.flip_h=true
		else:
			$AnimatedSprite2D.flip_h=false

func kill():
	queue_free()

func stun():
	print("Enemy is Stunned!")
	stunned = true
	$StunTimer.start()
	$StunParticles.emitting = true

func idle(delta):
	if !stunned:
		idle_timer -= delta
		if idle_timer <= 0:
			if idle_moving:
				idle_moving = false
				idle_timer = idle_wait_duration
				current_velocity = Vector2.ZERO
				$AnimatedSprite2D.play("idle")
			else:
				var angle = randf() * TAU
				idle_direction = Vector2(cos(angle), sin(angle)).normalized()
				idle_target_position = global_position + idle_direction * 10
				idle_moving = true
				idle_timer = idle_move_duration

		if idle_moving:
			move(idle_target_position, delta, 0.5)
		else:
			current_velocity = Vector2.ZERO
	else: #is stunned
		velocity = Vector2.ZERO

func take_damage(damage: int):
	if (health-damage<=0):
		health = 0
		print("Slime has died")
		kill()
	else:
		health -= damage;
		print("Slime has taken damage! Health is now: ", health)
		#start damage timer


func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true
	
func _on_detection_area_body_exited(body: Node2D) -> void:
	player_chase = false


func enemy():
	pass


func _on_stun_timer_timeout() -> void:
	stunned = false 
	$StunParticles.emitting = false  
