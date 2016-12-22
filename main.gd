extends Node2D

var map
var mapCells = []
var selectedTiles = []

var tilesTypes
var character
var structureSelected
var tileSize = Vector2(150, 122)
var structure = {
	"mine": 0,
	"temple": 0,
	"farm": 0,
	"tower": 0,
	"town": 0
}

var totalResources = {
	"gold": 10,
	"experience": 0,
	"food": 0
}

var costs = {
	"mine": 10,
	"temple": 15,
	"farm": 10
}

func _ready():
	prepareTiles()
	initCharacter()
	generateUI()
		
	#set_process(true)
	set_process_input(true)
	
func generateUI():
	var menuScene = load("res://menu.tscn")
	var menu = menuScene.instance()
	var screenSize = get_viewport().get_rect().size
	
	self.get_node("ui").add_child(menu)
	
	var menuPosition = screenSize - menu.get_size()
	
	menuPosition.x -= 90
	menuPosition.y -= 50

	menu.set_pos(menuPosition)
	
	var panelScene = load("res://panel.tscn")
	var panel = panelScene.instance()
		
	self.get_node("ui").add_child(panel)
	
	var panelPosition = Vector2(0, 0)

	panel.set_size(Vector2(screenSize.width, 50))
	panel.set_pos(panelPosition)	

func neighborsVector(cords, valid = false):
	var result = {}
	
	var vectors = [
		Vector3(cords.x, cords.y + 1, cords.z - 1),
		Vector3(cords.x + 1, cords.y, cords.z - 1),
		Vector3(cords.x - 1, cords.y + 1, cords.z),
		Vector3(cords.x, cords.y - 1, cords.z + 1),
		Vector3(cords.x + 1, cords.y - 1, cords.z),
		Vector3(cords.x - 1, cords.y, cords.z + 1)	
	]
	
	result.top = vectors[0]
	result.topRight = vectors[1]
	result.topLeft = vectors[2]
	result.bottom = vectors[3]
	result.bottomRight = vectors[4]
	result.bottomLeft = vectors[5]
	
	var validVector = []
	
	if valid:
		for cell in mapCells:
			if cell.node.canMove() && vectors.has(cell.cube):
				validVector.append(cell.cube)

		for obj in result.keys():
			if !validVector.has(result[obj]):
				result.erase(obj)

	return result

func neighbors(init, valid = false):
	var result = {
		"top": null,
		"topRight": null,
		"topLeft": null,
		"bottom": null,
		"bottomRight": null,
		"bottomLeft": null
	}
	var tilesNeighbor = neighborsVector(init, valid)

	for cell in mapCells:
		if tilesNeighbor.has("top") && result.top == null && cell.cube == tilesNeighbor.top:
			result.top = cell
		elif tilesNeighbor.has("topRight") && result.topRight == null && cell.cube == tilesNeighbor.topRight:
			result.topRight = cell			
		elif tilesNeighbor.has("topLeft") && result.topLeft == null && cell.cube == tilesNeighbor.topLeft:
			result.toptopLeft = cell	
		elif tilesNeighbor.has("bottom") && result.bottom == null && cell.cube == tilesNeighbor.bottom:
			result.bottom = cell
		elif tilesNeighbor.has("bottomRight") && result.bottomRight == null && cell.cube == tilesNeighbor.bottomRight:
			result.bottomRight = cell
		elif tilesNeighbor.has("bottomLeft") && result.bottomLeft == null && cell.cube == tilesNeighbor.bottomLeft:
			result.bottomLeft = cell

	return result

func breadthFirstSearch(start, goal):
	var frontier = []
	frontier.append(start)
	var came_from = {}
	came_from[start] = null
	
	while !frontier.empty():
		var current = frontier[0]
		frontier.pop_front()

		if current == goal: 
			break           

		var neighborsList = []
		var neighborsTiles = neighborsVector(current, true)
		
		for obj in neighborsTiles.keys():
			neighborsList.append(neighborsTiles[obj])
		
		for next in neighborsList:
			if !came_from.has(next):
				frontier.append(next)
				came_from[next] = current
	
	var current = goal 
	var path = [current]
	
	while current != start: 
		current = came_from[current]
		path.append(current)
		
	return path
	
func axialToCube(axial):
	var cube = Vector3()
	
	cube.x = axial.x
	cube.z = axial.y
	cube.y = -cube.x-cube.z
	
	return cube
	
func showPath(path):
	for cell in mapCells:
		if path.has(cell.cube):
			cell.node.get_node("hover").show()
			
func hidePath(path):
	for cell in mapCells:
		if path.has(cell.cube):
			cell.node.get_node("hover").hide()
	
func _button_pressed(viewport, event, shape, node):
	if(event.type == InputEvent.MOUSE_BUTTON && event.button_index == BUTTON_LEFT && event.pressed == 0):	
		if node.has_node("selected"):
			node.addStructure(structureSelected)
			cleanSelectedNodes()
	
	if(event.type == InputEvent.MOUSE_BUTTON && event.button_index == BUTTON_RIGHT && event.pressed == 0):	
		if node.canMove() && !character.moving:
			var path = breadthFirstSearch(character.cube, node.cube)
			
			showPath(path)
			
			var pathCords = []
			
			for p in path:
				for cell in mapCells:
					if cell.cube == p:
						pathCords.append(cell.node.get_pos())
			
			# remove the initial position
			pathCords.invert()
			pathCords.pop_front()

			character.moveTo(pathCords, path)
			character.cube = node.cube

var drag = false
var initPosCam = false
var initPosMouse = false
var initPosNode = false

func _input(event):
	var mouse_pos = get_global_mouse_pos()
	
	var zoom = get_node("camera").get_zoom()
	var zoomStep = 0.10
	
	if (event.is_action_pressed("ui_cancel")):
        self.get_tree().quit()

	if (event.type == InputEvent.MOUSE_MOTION):
		if(drag == true):
			var mouse_pos = get_global_mouse_pos()

			var dist_x = initPosMouse.x - mouse_pos.x
			var dist_y = initPosMouse.y - mouse_pos.y
			
			var nx = initPosNode.x - (0 + dist_x)
			var ny = initPosNode.y - (0 + dist_y)
		
			get_node("main").set_pos(Vector2(nx,ny))
	
	if (event.type == InputEvent.MOUSE_BUTTON):
		if (event.button_index == BUTTON_WHEEL_DOWN):
			zoom[0] = zoom[0] + zoomStep
			zoom[1] = zoom[1] + zoomStep
			
		if (event.button_index == BUTTON_WHEEL_UP):
			if(zoom[0] - zoomStep > 0 && zoom[1] - zoomStep > 0):
				zoom[0] = zoom[0] - zoomStep
				zoom[1] = zoom[1] - zoomStep
				
		if (event.button_index == BUTTON_MIDDLE):
			if(Input.is_mouse_button_pressed(3)):
				initPosMouse = get_global_mouse_pos()
				initPosNode = get_node("main").get_pos()
				drag = true
			else:
				drag = false	
				
		get_node("camera").set_zoom(zoom)
			
func prepareTiles():
	tilesTypes = {}
	tilesTypes.selected = load("res://selected.tscn")
	tilesTypes.rock = load("res://tile1.tscn")
	tilesTypes.grass = load("res://tile_grass.tscn")
	tilesTypes.water = load("res://tile_water.tscn")
	tilesTypes.structures = {}
	tilesTypes.structures.mine = load("res://structures/mine.tscn")
	tilesTypes.structures.temple = load("res://structures/temple.tscn")
	tilesTypes.structures.farm = load("res://structures/farm.tscn")
	
	tilesTypes.resources = {}
	tilesTypes.resources.tower = load("res://structures/tower.tscn")
	tilesTypes.resources.town = load("res://structures/town.tscn")	
	tilesTypes.resources.mountain = load("res://structures/mountain.tscn")
	tilesTypes.resources.forest = load("res://structures/forest.tscn")
	
func initCharacter():
	var characterScene = load("res://character.tscn")
	
	character = characterScene.instance()
	self.get_node("main").add_child(character)
	
	character.set_pos(Vector2(10, 30))
	character.set_z(10)
	character.cube = Vector3(0, 0, 0)

	var tileHome = showTile(character.get_pos(), Vector3(0,0,0), {"type": "rock", "resource": "tower"})
	showAdjacentTiles(tileHome)
	
	var pos = Vector2(tileHome.get_pos().x, tileHome.get_pos().y)
	pos.y +=  tileSize.y * 3
	
	var tileTown = showTile(pos, Vector3(0, -3, 3), {"type": "rock", "resource": "town"})
	showAdjacentTiles(tileTown)

func selectTile(node):
	var selected = tilesTypes.selected.instance()
	selected.set_z(8)
	node.add_child(selected)
	selectedTiles.append(node)
	
func unSelectTile(node):
	node.remove_child(node.get_node("selected"))
	
func prepareBuild(type):
	structureSelected = type
	
	var characterTile = getTileByCube(character.cube)
	var tiles = neighbors(character.cube, true)

	if structureSelected == "mine":
		if characterTile.node.hasResource("mountain") && !characterTile.node.hasStructure("mine"):
			selectTile(characterTile.node)
	
		for tile in tiles.keys():
			if tiles[tile] != null && tiles[tile].node.hasResource("mountain") && !tiles[tile].node.hasStructure("mine"):
				selectTile(tiles[tile].node)
	elif structureSelected == "temple":
		if characterTile.node.hasResource("forest") && !characterTile.node.hasStructure("temple"):
			selectTile(characterTile.node)
	
		for tile in tiles.keys():
			if tiles[tile] != null && tiles[tile].node.hasResource("forest") && !tiles[tile].node.hasStructure("temple"):
				selectTile(tiles[tile].node)
	elif structureSelected == "farm":
		print("farrrm!")
		if characterTile.node.type == "grass" && characterTile.node.structure == null && characterTile.node.resource == null:
			selectTile(characterTile.node)
	
		for tile in tiles.keys():
			if tiles[tile] != null && tiles[tile].node.type == "grass" && tiles[tile].node.structure == null && tiles[tile].node.resource == null:
				selectTile(tiles[tile].node)
						
func cleanSelectedNodes():
	for tile in selectedTiles:
		unSelectTile(tile)
		
	selectedTiles = []
	
func showAdjacentTilesByCords(pos):
	var tile = getTileByPos(pos)
	showAdjacentTiles(tile.node)

func showAdjacentTiles(node):
	var pos
	var cube = node.cube
	
	var neighbors = neighborsVector(cube)
	
	# top
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.y -=  tileSize.y
	
	if getTileByPos(pos) == null:
		showTile(pos, neighbors.top)	
	
	# top-right
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.x +=  tileSize.x
	pos.y -=  tileSize.y / 2
	
	if getTileByPos(pos) == null:
		showTile(pos, neighbors.topRight)	
	
	# top-left
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.x -=  tileSize.x
	pos.y -=  tileSize.y / 2
	
	if getTileByPos(pos) == null:
		showTile(pos, neighbors.topLeft)	
	
	# bottom
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.y +=  tileSize.y
	
	if getTileByPos(pos) == null:
		showTile(pos, neighbors.bottom)		
	
	# bottom-right
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.x +=  tileSize.x
	pos.y +=  tileSize.y / 2
	
	if getTileByPos(pos) == null:
		showTile(pos, neighbors.bottomRight)		

	# bottom-left
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.x -=  tileSize.x
	pos.y +=  tileSize.y / 2	
		
	if getTileByPos(pos) == null:
		showTile(pos, neighbors.bottomLeft)		

func getTileByPos(pos):
	for cell in mapCells:
		if cell.pos == pos:
			return cell
			
	return null	
	
func getTileByCube(cube):
	for cell in mapCells:
		if cell.cube == cube:
			return cell
			
	return null		
	
func randomTile():
	var randTileType = randi() % 100
	var tileType
	
	if randTileType < 65:
		tileType = "grass"
	elif randTileType < 85:
		tileType = "rock"
	else:
		return {
			"type": "water"
		}
	
	var randTileResource = randi() % 100
	var tileResource = null
	
	if randTileResource < 60:
		tileResource = null
	elif randTileResource < 85:
		tileResource = "forest"
	else:
		tileResource = "mountain"

	return {
		"type": tileType,
		"resource": tileResource
	}
	
func bought(type):
	if costs.has(type):
		totalResources["gold"] -= costs[type]	
	
func addResource(tile, type):
	tile.addResource(type)
	
func addStructure(tile, type):
	tile.addStructure(type)
			
func showTile(center, cube, type = null):
	var tile
	if type == null:
		tile = randomTile()
	else:
		tile = type

	var tileIns = tilesTypes[tile.type].instance()
	
	get_node("main/map").add_child(tileIns)
	tileIns.set_pos(center)
	tileIns.set_z(center.y)
	tileIns.cube = cube
	
	if tile.has("resource") && tile.resource != null:
		tileIns.get_node("AnimationPlayer").connect("finished", self, "addResource", [tileIns, tile.resource])
		
	if tile.has("structure") && tile.structure != null:
		tileIns.get_node("AnimationPlayer").connect("finished", self, "addStructure", [tileIns, tile.structure])
	
	if tileIns.get_z() > character.get_z():
		character.set_z(tileIns.get_z() + 1)

	tileIns.get_node("area").connect("input_event", self, "_button_pressed", [tileIns])
	tileIns.get_node("AnimationPlayer").play(tileIns.getAnimation())	
	
	var tile = {
		"node": tileIns,
		"cube": cube,
		"pos": center
	}
	
	mapCells.append(tile)
	
	var showLabel = true
	
	if showLabel:
		var text = Label.new()
		text.set_text(str(tileIns.cube.x, ",", tileIns.cube.y, ",", tileIns.cube.z))
		tileIns.add_child(text)
		text.set_owner(tileIns)
			
	removeNotBorderAnimations()
	
	return tileIns
	
func removeNotBorderAnimations():
	for cell in mapCells:
		var removeBottom = false
		var removeLeft = false
		var removeRight = false

		for search in mapCells:
			if (search.cube.y == cell.cube.y - 1 && 
				search.cube.x == cell.cube.x + 1 &&
				search.cube.z == cell.cube.z):
				removeRight = true
				
			if (search.cube.y == cell.cube.y && 
				search.cube.x == cell.cube.x - 1 && 
				search.cube.z == cell.cube.z + 1):
				removeLeft = true				
			
			if (search.cube.x == cell.cube.x && 
				search.cube.y == cell.cube.y - 1 &&
				search.cube.z -1 == cell.cube.z):
				removeBottom = true				

		if removeBottom && cell.node.has_node("Water_1"):
			cell.node.remove_child(cell.node.get_node("Water_1"))
			
		if removeRight && cell.node.has_node("Water_2"):
			cell.node.remove_child(cell.node.get_node("Water_2"))
			
		if removeLeft && cell.node.has_node("Water_3"):
			cell.node.remove_child(cell.node.get_node("Water_3"))

# #	var sorter = CellsSorter.new()
# 	mapCells.sort_custom(sorter, "sortY")
#class CellsSorter:
#	func sortX(cell1, cell2):
#		return cell1.axial.x > cell2.axial.x
#		
#	func sortY(cell1, cell2):
#		return cell1.axial.y > cell2.axial.y
