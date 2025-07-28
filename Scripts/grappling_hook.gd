extends CharacterBody2D
#mechanic for grappling where it fails and you have to fix it, or it will malfunction kinda stunning you
@export var speed = 300
var direction = Vector2.ZERO
var player: CharacterBody2D  # reference to player
var mode : int = 0; # mode 0 is idle, mode 1 is throw, mode 2 is timeout
var throw_position : Vector2 = Vector2.ZERO
var parallel_velocity : Vector2
var hook_attached = false
var enemy : Node2D

@export var travel_time: float = 2

var elapsed_time := 0.0

var displacement

signal grappleConnect

#TODO  set up a proper sprite for it, 
#TODO  set up a chain of some sort
#TODO pull enemies
func _ready():
	pass


func _process(delta):
	
	if mode == 0:
		idle()
	if mode == 1:
		throw()
	if mode == 2:
		timeout(delta)
	move_and_slide()

func idle_init():
	mode = 0
	$CooldownTimer.start()
	if enemy:
		enemy.rotation = 0
	enemy = null
	hook_attached = false

func idle():
	if player:
		global_position = get_grapple_rest_position()
		rotation = (get_global_mouse_position() - player.global_position).angle() + PI/2

func throw_init(mouse_position, init_velocity):
	direction = (mouse_position - global_position).normalized()
	print("Throw passed")
	mode = 1
	$ThrowTimer.start()
	rotation=direction.angle()
	
	parallel_velocity = get_parallel_component(init_velocity, direction)
	rotation = direction.angle() + PI/2
	velocity = direction.normalized() * speed + parallel_velocity/4
	


func get_parallel_component(vector: Vector2, direction: Vector2) -> Vector2:
 	
  #Calculates the component of vector that is parallel to direction.

  #Args:
	#vector: The vector whose parallel component is to be found.
	#direction: The vector to project onto.

  #Returns:
	#The parallel component of vector.

	var direction_normalized = direction.normalized()
	var dot_product = vector.dot(direction_normalized)
	return direction_normalized * dot_product


func get_grapple_rest_position() -> Vector2:
	return player.global_position - (player.global_position - get_global_mouse_position()).normalized() * 30

func throw():
	var dist = global_position.distance_to(throw_position)
	
	if dist < 10:
		velocity = Vector2.ZERO

func timeout_init():
	mode = 2
	$TimeoutTimer.start()
	displacement = global_position
	velocity = Vector2.ZERO
	elapsed_time = 0.0

func  timeout(delta):

	elapsed_time += delta
	var t: float = elapsed_time / travel_time
	var target_position: Vector2 = get_grapple_rest_position()

	rotation = velocity.angle() - PI/2
	if t >= 1.0:
		global_position = target_position
		if enemy:
			enemy.global_position = target_position
	else:
		global_position = displacement.lerp(target_position, t)
		
		rotation = (global_position - target_position).angle() + PI/2
		if enemy:
			enemy.global_position = global_position + Vector2.LEFT
			enemy.rotation = rotation

func grapple_empty_retract():
	print("empty rectract :(")
	#return the grappling hook to the player, no mobs attached.

func grapple_full_retract():
	print("Full retract!")
	enemy.stun()
	hook_attached = true
	$HitEffect.emitting = true
	$TimeoutTimer.stop()
	timeout_init()
	#pull enemy toward the player, stunning it

func _on_timeout_timer_timeout() -> void:
	print("TIMEOUT!")
	idle_init() # Replace with function body.

func _on_cooldown_timer_timeout() -> void:
	player.grapple_ready = true # Replace with function body.


func _on_throw_timer_timeout() -> void:
	timeout_init() # Replace with function body.


func _on_grapple_area_body_entered(body: Node2D) -> void:
	if(mode == 1 || mode == 2):
		if !hook_attached:
			if(body.has_method("enemy")):
				enemy = body
				grapple_full_retract()
