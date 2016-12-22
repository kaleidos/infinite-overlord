extends "Tile.gd"

var cube
var type = "grass"
var resource = null
var structure = null

func _ready():
	pass

func canMove():
	return true
	
func getAnimation():
	return "tile_appear_grass"