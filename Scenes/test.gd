extends Node2D
func _ready():
	var HookScene = preload("res://Scenes/grappling_hook.tscn")
	var hook_instance = HookScene.instantiate()
	print("hook_instance:", hook_instance)
	if hook_instance == null:
		print("❌ Failed to instantiate hook scene")
	else:
		print("✅ Hook instantiated successfully")
		get_tree().root.add_child(hook_instance)
