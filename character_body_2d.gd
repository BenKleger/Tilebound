extends CharacterBody2D

#constants
const max_health = 100

#variables
var player = null
var player_in_chase_range = false
var player_in_attack_range = false
var chase_range = 1000
var attack_range = 100
var attack_ready = true
var health = 100
var type = 0 #0 = enemy, 1 = allied / summoned creatures

func enemy():
	pass

func _physics_process(delta: float):
	range_checker()
	
	if(player_in_chase_range):
		chase()
	elif(player_in_attack_range && attack_ready):
		attack()
	else:
		idle()

func stun():
	pass
	
func die():
	queue_free()
	pass
	#mob dies TODO

#would take negative damage to heal sucessfully
func take_damage(damage: int):
	if damage > 0: #taking damage
		if damage < health:
			health -= damage;
		else:
			health = 0;
			die()
	else: 	 	#healing --> negative damage
		if health-damage <= max_health:
			health -= damage
		else: 
			health = max_health

func range_checker():
	pass

func _init():
	idle()
	
func idle():
	$AnimationPlayer.play("idle")
	#maybe add some slight movement around so its not just sitting there waiting for the player?

func chase():
	$AnimationPlayer.play("chase")
	#do movement

func attack():
	$AnimationPlayer.play("attack")
	$AttackTimer.start();

func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_in_chase_range = true
	
func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_in_chase_range = false
