extends Node2D
func _process(delta):
		get_veloc(movement_direction_calculator(), delta);
		
	
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



		return direction

func get_veloc(input: Vector2, delta) -> void:
	
	#all this stuff was mostly just from the previous game, want to make it more responsive movement, give some 'friction' in air keeping some velocity, not being perfectly responsive... unless?? just slowed down?
			
			position.x += input.x
			position.y += input.y
