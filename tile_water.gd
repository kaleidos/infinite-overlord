extends Node2D

var cube

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func canMove():
	return false
	
func getAnimation():
	return "tile_appear_water"	