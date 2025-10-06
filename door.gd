extends Area2D

var state = "closed"
var opening = false

var player = null
#TODO var to_room
#TODO to_rooms' reward(?)
#TODO

func _process(_delta):
	if state == "closed":
		$AnimatedSprite2D.play("closed")
	elif state == "opening":
		pass
	else:
		$AnimatedSprite2D.play("open")
		if player:
			if(Input.is_action_just_pressed("ui_accept")):
				pass
				#TODO load next room

func open():
	state = "opening"
	$AnimatedSprite2D.play("opening")
	$OpenTimer.start()

func _on_open_timer_timeout() -> void:
	state = "open"


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body

func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
