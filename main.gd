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
	
#	if (event.type == InputEvent.MOUSE_BUTTON):
#		if (event.button_index == 5):
#			zoom[0] = zoom[0] + zoomStep
#			zoom[1] = zoom[1] + zoomStep
#		if (event.button_index == 4):
#			if(zoom[0] - zoomStep > 0 && zoom[1] - zoomStep > 0):
#				zoom[0] = zoom[0] - zoomStep
#				zoom[1] = zoom[1] - zoomStep
#				
#		get_node("camera").set_zoom(zoom)
			
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

	var tile = showTile(character.get_pos(), Vector2(0,0))
	
	showAdjacentTiles(tile)

func showAdjacentTiles(node):
	var tileSize = Vector2(150, 122)
	var pos
	var axial = node.axial
	
	# top
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.y -=  tileSize.y
	
	if getTileByPos(pos) == null:
		showTile(pos, Vector2(axial.x, axial.y - 1))	
	
	# top-right
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.x +=  tileSize.x
	pos.y -=  tileSize.y / 2
	
	if getTileByPos(pos) == null:
		showTile(pos, Vector2(axial.x + 1, axial.y - 1))	
	
	# top-left
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.x -=  tileSize.x
	pos.y -=  tileSize.y / 2
	
	if getTileByPos(pos) == null:
		showTile(pos, Vector2(axial.x - 1, axial.y))	
	
	# bottom
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.y +=  tileSize.y
	
	if getTileByPos(pos) == null:
		showTile(pos, Vector2(axial.x, axial.y + 1))		
	
	# bottom-right
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.x +=  tileSize.x
	pos.y +=  tileSize.y / 2
	
	if getTileByPos(pos) == null:
		showTile(pos, Vector2(axial.x + 1, axial.y))		

	# bottom-left
	pos = Vector2(node.get_pos().x, node.get_pos().y)
	pos.x -=  tileSize.x
	pos.y +=  tileSize.y / 2	
		
	if getTileByPos(pos) == null:
		showTile(pos, Vector2(axial.x - 1, axial.y + 1))		

func getTileByPos(pos):
	for cell in mapCells:
		if cell.pos == pos:
			return cell
			
	return null	
	
func showTile(center, axial = null):
	var tile = tilesTypes.all[randi() % tilesTypes.all.size()]

	var tileIns = tilesTypes[tile].instance()
	
	get_node("main/map").add_child(tileIns)
	tileIns.set_pos(center)
	tileIns.set_z(center.y)
	tileIns.axial = axial
	
	if tileIns.get_z() > character.get_z():
		character.set_z(tileIns.get_z() + 1)

	tileIns.get_node("area").connect("input_event", self, "_button_pressed", [tileIns])
	tileIns.get_node("AnimationPlayer").play(tileIns.getAnimation())	
	
	var tile = {
		"node": tileIns,
		"axial": axial,
		"pos": center
	}
	
	mapCells.append(tile)
	
	var showLabel = false
	
	if showLabel:
		var text = Label.new()
		text.set_text(str(tileIns.axial.x, ",", tileIns.axial.y))
		tileIns.add_child(text)
		text.set_owner(tileIns)
			
	removeNotBorderAnimations()
	
	return tileIns
	
func removeNotBorderAnimations():
#	var sorter = CellsSorter.new()
#	mapCells.sort_custom(sorter, "sortX")
#	
#	var maxX = mapCells[0].axial.x
#	
#	mapCells.sort_custom(sorter, "sortY")
#	
#	var maxY = mapCells[0].axial.y
	
	for cell in mapCells:
		var removeBottom = false
		var removeLeft = false
		var removeRight = false

		for search in mapCells:
			if (search.axial.y == cell.axial.y && 
				search.axial.x == cell.axial.x + 1):
				removeRight = true
				
			if (search.axial.y == cell.axial.y + 1 && 
				search.axial.x == cell.axial.x - 1):
				removeLeft = true				

			if (search.axial.x == cell.axial.x && 
				search.axial.y == cell.axial.y + 1):
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
