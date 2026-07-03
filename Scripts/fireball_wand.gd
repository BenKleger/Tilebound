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
var rotation_amount
var rest_position
var shoot_ready: bool = true
var spread = 0.1#.05 #for bullet, 1 ~ 180 degree spread


@export var travel_time: float = 1

var elapsed_time := 0.0

var displacement

signal grappleConnect

#TODO  set up a proper sprite for it, 
#TODO  set up a chain of some sort
#TODO pull enemies
func _ready():
	pass


func _process(_delta):
	
	if mode == 0:
		idle()
	move_and_slide()


func idle():
	if player:
		global_position = rest_position
		rotation = (get_global_mouse_position()-rest_position).angle() + PI/2

func shoot():
	
	if(shoot_ready):
		
		
		#TODO Complete revamp of this system... want to have individual weapons, each orbiting around the player,
		 #similar to the grappling hook system and when the player 'shoots' it calls all the weapons to fire
		var bullet = preload("res://Scenes/projectile.tscn").instantiate()
		
		bullet.position = global_position
		var temp = (get_global_mouse_position()-global_position).normalized()
		bullet.direction.x = randf_range(temp.x-spread,temp.x+spread)
		bullet.direction.y = randf_range(temp.y-spread,temp.y+spread)
		bullet.init_velocity = player.velocity
		bullet.damage = 5
		bullet.player_projectile = true
		#bullet.sprite_texture = preload("res://assets/bullet.png")
		get_tree().current_scene.add_child(bullet)
		shoot_ready = false
		
		$ShootTimer.start()


func get_parallel_component(vector: Vector2, Direction: Vector2) -> Vector2:
 	
  #Calculates the component of vector that is parallel to direction.

  #Args:
	#vector: The vector whose parallel component is to be found.
	#direction: The vector to project onto.

  #Returns:
	#The parallel component of vector.

	var direction_normalized = Direction.normalized()
	var dot_product = vector.dot(direction_normalized)
	return direction_normalized * dot_product


func _on_cooldown_timer_timeout() -> void:
	player.grapple_ready = true # Replace with function body.


func _on_shoot_timer_timeout() -> void:
	shoot_ready = true
