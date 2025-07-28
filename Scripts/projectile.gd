extends Area2D

var player_projectile : bool #if true it's a player generated projectile --> can't damage player, can damage the enemies and vice versa
var image #??

@export var speed: float = 400.0
@export var damage: int = 5
@export var sprite_texture: Texture2D
@export var duration: float = 1
@export var angular_velocity = 100
var killed = false
var init_velocity: Vector2
var parallel_velocity: Vector2
var direction: Vector2 = Vector2.RIGHT

func _ready():
	$Timer.wait_time = duration
	parallel_velocity = get_parallel_component(init_velocity, direction)
	$Timer.start()
	rotation = parallel_velocity.angle()

#want relative motion, but also bullt travelling to where the destination is --> vector math prolly :)
#so hear me out
func _process(delta):
	rotation += angular_velocity * delta
	if !killed:
		position += direction.normalized() * speed * delta + parallel_velocity/4 * delta
	else:
		position += (direction.normalized() * speed * delta + parallel_velocity/4 * delta) / 10


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

func kill():
	killed = true
	$GPUParticles2D.emitting = false
	$AnimatedSprite2D.play("dissipate")
	$CollisionShape2D.set_deferred("disabled", true)
	$DeathTimer.start()
	#add some animation player stuffs


func _on_body_entered(body):
	print("BodyEntered!")
# Deal damage or call a method on the body
	if(player_projectile):
		#damage if it is an enemy
		if(body.has_method("enemy")):
			body.take_damage(damage)
			kill()
			print(1)
	else:
		#damage it if it's a player
		if(body.has_method("player")):
			body.enemy_attack(damage)
			kill()
			print(2)


func _on_timer_timeout() -> void:
	print("BulletTimer")
	kill() # Replace with function body.


func _on_death_timer_timeout() -> void:
	queue_free() # Replace with function body.
