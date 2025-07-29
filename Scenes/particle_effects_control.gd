extends CheckButton


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		GlobalVariables.particles_on = true;
	else:
		GlobalVariables.particles_on = false;
	print(GlobalVariables.particles_on)
