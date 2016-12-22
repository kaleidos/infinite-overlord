extends "Tile.gd"

var cube
var type = "water"
var resource = null
var structure = null

func _ready():
	pass

func canMove():
	return false
	
func getAnimation():
	return "tile_appear_water"	