extends Node2D

var ParticleMaterial := $DashParticles.process_material as ParticleProcessMaterial

func spawn_stuff(last_input):
	var angle = rad_to_deg(last_input.angle())
	#fucking dumb ass fix for the cursed issue with rotation
		ParticleMaterial.angle_min = angle - 5
		ParticleMaterial.angle_max = angle + 5
	else:
		# Cardinal — offset 90° to align visuals
		ParticleMaterial.angle_min = angle + 85
		ParticleMaterial.angle_max = angle + 95
	$DashParticles.restart()
	$DashParticles.emitting = true
