extends Node2D

var map
var mapCells = []
var scale = Vector2(0.4, 0.4)

var tilesTypes
var character

func _ready():
	#map = get_node("map")
	
	prepareTiles()
#	storeMapCells()
	
	var sorter = CellsSorter.new()
	mapCells.sort_custom(sorter, "sort")
	
#	for cell in mapCells:
#		var cellPosition = map.map_to_world(cell.position)
#		
#		var nodeRock = tile1RockScene.instance()
#		add_child(nodeRock)
#		nodeRock.set_pos(cellPosition)
#		nodeRock.set_z(cell.position.y)
#		nodeRock.get_node("area").connect("input_event", self, "_button_pressed", [nodeRock])
#		#nodeRock.get_node("AnimationPlayer").play("Appear")
		
	initCharacter()
		
	set_process(true)
	set_process_input(true)
	
func _button_pressed(viewport, event, shape, node):
	if(event.type == InputEvent.MOUSE_BUTTON && event.button_index == BUTTON_RIGHT && event.pressed == 0):		
		character.moveTo(node.get_pos())

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

#func _input(event):
#	if(event.type == InputEvent.MOUSE_BUTTON && event.button_index == BUTTON_RIGHT):
#		print(event)
#		characterToPosition(event.pos)
		
#func characterToPosition(pos): 
#	character.set_pos(pos)
	
#func hideCell(cell):
#	map.set_cell(cell.x, cell.y, -1)
#	
#func storeMapCells():
#	var cells = map.get_used_cells()
#	
#	for cell in cells:
#		var cellIndex = map.get_cellv(cell)
#		var tile = {
#			"index": cellIndex,
#			"position": cell,
#			"worldPosition": map.map_to_world(cell)
#		}
#
#		mapCells.append(tile)
#		
#		#hideCell(cell)
		
#func showTile(position, animation = false):
#	for cell in mapCells:
#		if cell.position == position:
#			#map.set_cell(cell.position.x, cell.position.y, cell.index)
#			
#			if animation:
#				print("------------")
#				var cellPosition = map.map_to_world(cell.position)
#				print(cellPosition)
#								
#				#var xx = Vector2(300, -(230/2))	
#				
#				cellPosition.x = cellPosition.x
#				cellPosition.y = cellPosition.y
#				
#				var nodeRock = tile1RockScene.instance()
#				add_child(nodeRock)
#				#nodeRock.set_scale(scale)
#				nodeRock.set_pos(cellPosition)
#				#nodeRock.get_node("AnimationPlayer").play("Appear")
#			else:
#				map.set_cell(cell.position.x, cell.position.y, cell.index)
			
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
	showTilePlayer("top")
	showTilePlayer("top-left")
	showTilePlayer("top-right")
	showTilePlayer("bottom")
	showTilePlayer("bottom-left")
	showTilePlayer("bottom-right")
	var pos = character.get_pos();
	pos.x +=  150
	pos.y -=  61
	showTile(pos)

func showTilePlayer(position):
	var tileSize = Vector2(150, 122)
	var pos = character.get_pos()	
	
	if position == "top":
		pos.y -=  tileSize.y
	elif position == "top-right":
		pos.x +=  tileSize.x
		pos.y -=  tileSize.y / 2
	elif position == "top-left":
		pos.x -=  tileSize.x
		pos.y -=  tileSize.y / 2
	elif position == "bottom":
		pos.y +=  tileSize.y
	elif position == "bottom-right":
		pos.x +=  tileSize.x
		pos.y +=  tileSize.y / 2
	elif position == "bottom-left":
		pos.x -=  tileSize.x
		pos.y +=  tileSize.y / 2		
	
	showTile(pos)	
	
func showTile(center):
	var nodeRock = tilesTypes.rock.instance()
	get_node("map").add_child(nodeRock)
	nodeRock.set_pos(center)
	nodeRock.set_z(center.y)
	
	if nodeRock.get_z() > character.get_z():
		character.set_z(nodeRock.get_z() + 1)

	nodeRock.get_node("area").connect("input_event", self, "_button_pressed", [nodeRock])
		#nodeRock.get_node("AnimationPlayer").play("Appear")	
	
func _process(delta):

	#print(tiles)
	#print(map.get_used_cells())
	#print(map.get_cellv(Vector2(1, 0)))
	#map.set_cell(1, 0, -1) # clear

	#var xx = Vector2(300, 570)	
	var xx = Vector2(300, -(230/2))	

	#nodeRock.set_pos(xx)
	#nodeRock.show()	
	
class CellsSorter:
    func sort(cell1, cell2):
        return cell1.worldPosition.y < cell2.worldPosition.y