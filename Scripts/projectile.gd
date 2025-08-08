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

func instantiate(isprite_texture: Texture2D, iangular_velocity = 100, iduration: float = 1, ispeed: float = 400.0, idamage: int = 5):
	speed = ispeed
	angular_velocity = iangular_velocity 
	sprite_texture = isprite_texture
	duration = iduration
	damage = idamage

func _ready():
	$Timer.wait_time = duration
	parallel_velocity = get_parallel_component(init_velocity, direction)
	$Timer.start()
	rotation = parallel_velocity.angle()
	$AnimatedSprite2D.play("default")
	if !GlobalVariables.particles_on:
		$TrailParticles.emitting = false

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
	if !GlobalVariables.particles_on:
		$AnimatedSprite2D.play("dissipate")
	killed = true
	$TrailParticles.emitting = false
	
	
	
	$CollisionShape2D.set_deferred("disabled", true)
	$DeathTimer.start()
	#add some animation player stuffs


func _on_body_entered(body):
	print("BodyEntered!")
# Deal damage or call a method on the body
	if(player_projectile):
		#damage if it is an enemy
		if(body.has_method("enemy")):
			$AnimatedSprite2D.hide()
			body.take_damage(damage)
			$Timer.stop()
			if GlobalVariables.particles_on:
				$HitParticles.emitting = true
			kill()
			print(1)
	else:
		#damage it if it's a player
		if(body.has_method("player")):
			$Timer.stop()
			if GlobalVariables.particles_on:
				$HitParticles.emitting = true
			$AnimatedSprite2D.play("dead")
			body.enemy_attack(damage)
			kill()
			print(2)


func _on_timer_timeout() -> void:
	print("BulletTimer")
	kill() # Replace with function body.
	$AnimatedSprite2D.play("dissipate")


func _on_death_timer_timeout() -> void:
	queue_free() # Replace with function body.
