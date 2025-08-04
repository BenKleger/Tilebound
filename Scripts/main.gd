extends Control

@onready var options: Panel = $Options
@onready var big_box: VBoxContainer = $BigBox
@onready var credits: Panel = $Credits

func _ready():
	big_box.visible = true
	options.visible = false
	credits.visible = false

func _on_start_pressed() -> void:
	#start game
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_options_pressed() -> void:
	big_box.visible = false
	options.visible = true
	credits.visible = false

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	big_box.visible = true
	options.visible = false
	credits.visible = false


func _on_credits_pressed() -> void:
	big_box.visible = false
	options.visible = false
	credits.visible = true
