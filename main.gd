extends Node2D

var map
var mapCells = []

var tilesTypes
var character

func _ready():
	prepareTiles()
	initCharacter()
		
	#set_process(true)
	set_process_input(true)

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

func neighbors(init):
	var result = {
		"top": null,
		"topRight": null,
		"topLeft": null,
		"bottom": null,
		"bottomRight": null,
		"bottomLeft": null
	}
	var tilesNeighbor = neighborsVector(init)

	for cell in mapCells:
		if result.top == null && cell.cube == tilesNeighbor.top:
			result.top = cell
		elif result.topRight == null && cell.cube == tilesNeighbor.topRight:
			result.topRight = cell			
		elif result.topLeft == null && cell.cube == tilesNeighbor.topLeft:
			result.toptopLeft = cell	
		elif result.bottom == null && cell.cube == tilesNeighbor.bottom:
			result.bottom = cell
		elif result.bottomRight == null && cell.cube == tilesNeighbor.bottomRight:
			result.bottomRight = cell
		elif result.bottomLeft == null && cell.cube == tilesNeighbor.bottomLeft:
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
	if(event.type == InputEvent.MOUSE_BUTTON && event.button_index == BUTTON_RIGHT && event.pressed == 0):	
		if node.canMove():
			var path = breadthFirstSearch(character.cube, node.cube)
			
			#prepareTilesPaht(path)
			
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
			
			showAdjacentTiles(node)

var drag = false
var initPosCam = false
var initPosMouse = false
var initPosNode = false

func _input(event):
	var mouse_pos = get_global_mouse_pos()
	
	var zoom = get_node("camera").get_zoom()
	var zoomStep = 0.10

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
	tilesTypes.rock = load("res://tile1.tscn")
	tilesTypes.grass = load("res://tile_grass.tscn")
	tilesTypes.water = load("res://tile_water.tscn")
	
	tilesTypes.all = ["rock", "grass", "water"]
	
func initCharacter():
	var characterScene = load("res://character.tscn")
	
	character = characterScene.instance()
	self.get_node("main").add_child(character)
	
	character.set_pos(Vector2(10, 30))
	character.set_z(10)
	character.cube = Vector3(0, 0, 0)

	var tile = showTile(character.get_pos(), Vector3(0,0,0))
	
	showAdjacentTiles(tile)

func showAdjacentTiles(node):
	var tileSize = Vector2(150, 122)
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
	
func showTile(center, cube):
	var tile = tilesTypes.all[randi() % tilesTypes.all.size()]

	var tileIns = tilesTypes[tile].instance()
	
	get_node("main/map").add_child(tileIns)
	tileIns.set_pos(center)
	tileIns.set_z(center.y)
	tileIns.cube = cube
	
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

		if removeBottom:
			cell.node.remove_child(cell.node.get_node("Water_1"))
			
		if removeRight:
			cell.node.remove_child(cell.node.get_node("Water_2"))
			
		if removeLeft:
			cell.node.remove_child(cell.node.get_node("Water_3"))

# #	var sorter = CellsSorter.new()
# 	mapCells.sort_custom(sorter, "sortY")
#class CellsSorter:
#	func sortX(cell1, cell2):
#		return cell1.axial.x > cell2.axial.x
#		
#	func sortY(cell1, cell2):
#		return cell1.axial.y > cell2.axial.y
