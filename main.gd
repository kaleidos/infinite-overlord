extends Node2D

var map
var mapCells = []
var scale = Vector2(0.4, 0.4)

var tilesTypes
var character

func _ready():
	prepareTiles()
	initCharacter()
		
	#set_process(true)
	set_process_input(true)
	
func _button_pressed(viewport, event, shape, node):
	if(event.type == InputEvent.MOUSE_BUTTON && event.button_index == BUTTON_RIGHT && event.pressed == 0):	
		if node.canMove():
			character.moveTo(node.get_pos())
			showAdjacentTiles(node)

func _input(event):
	var zoom = get_node("camera").get_zoom()
	var zoomStep = 0.10
	
	if (event.type == InputEvent.MOUSE_BUTTON):
		if (event.button_index == 5):
			zoom[0] = zoom[0] + zoomStep
			zoom[1] = zoom[1] + zoomStep
		if (event.button_index == 4):
			if(zoom[0] - zoomStep > 0 && zoom[1] - zoomStep > 0):
				zoom[0] = zoom[0] - zoomStep
				zoom[1] = zoom[1] - zoomStep
				
		get_node("camera").set_zoom(zoom)
			
func prepareTiles():
	tilesTypes = {}
	tilesTypes.rock = load("res://tile1.tscn")
	tilesTypes.grass = load("res://tile_grass.tscn")
	tilesTypes.water = load("res://tile_water.tscn")
	
	tilesTypes.all = ["rock", "grass", "water"]
	
func initCharacter():
	var characterScene = load("res://character.tscn")
	
	character = characterScene.instance()
	add_child(character)
	
	character.set_pos(Vector2(10, 30))
	character.set_z(10)
	showTile(character.get_pos())
	
	# 150x122
	showAdjacentTiles(character)

func showAdjacentTiles(node):
	print(node.get_pos())
	var tileSize = Vector2(150, 122)
	var pos
	
	# top
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.y -=  tileSize.y
	
	if getTileByPos(pos) == null:
		showTile(pos)	
	
	# top-right
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.x +=  tileSize.x
	pos.y -=  tileSize.y / 2
	
	if getTileByPos(pos) == null:
		showTile(pos)	
	
	# top-left
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.x -=  tileSize.x
	pos.y -=  tileSize.y / 2
	
	if getTileByPos(pos) == null:
		showTile(pos)	
	
	# bottom
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.y +=  tileSize.y
	
	if getTileByPos(pos) == null:
		showTile(pos)	
	
	# bottom-right
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.x +=  tileSize.x
	pos.y +=  tileSize.y / 2
	
	if getTileByPos(pos) == null:
		showTile(pos)	

	# bottom-left
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.x -=  tileSize.x
	pos.y +=  tileSize.y / 2	
		
	if getTileByPos(pos) == null:
		showTile(pos)	
		
func getTileByPos(pos):
	for cell in mapCells:
		if cell.pos == pos:
			return cell
			
	return null	
	
func showTile(center):
	var tile = tilesTypes.all[randi() % tilesTypes.all.size()]

	var nodeRock = tilesTypes[tile].instance()
	
	get_node("map").add_child(nodeRock)
	nodeRock.set_pos(center)
	nodeRock.set_z(center.y)
	
	if nodeRock.get_z() > character.get_z():
		character.set_z(nodeRock.get_z() + 1)

	nodeRock.get_node("area").connect("input_event", self, "_button_pressed", [nodeRock])
		#nodeRock.get_node("AnimationPlayer").play("Appear")	
	
	var tile = {
		"pos": center
	}
	
	mapCells.append(tile)
