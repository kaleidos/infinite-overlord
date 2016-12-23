extends Node2D

func _ready():
	set_process_input(true)

func _input(event):
	if (event.is_action_pressed("ui_cancel")):
        self.get_tree().quit()

func _on_StartButton_button_up():
	get_tree().change_scene("res://main.tscn")
