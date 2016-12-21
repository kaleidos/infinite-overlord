extends Node2D

func _ready():
	setViewport()

func setViewport():
	var mainViewport = get_node("/root")
	var height = mainViewport.get_rect().size.y
	var width = mainViewport.get_rect().size.x
	
	var viewport = get_node("Control/Viewport")
	get_node("Control").set_size(Vector2(width,height))
	