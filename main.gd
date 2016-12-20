extends Node2D

var map
var mapCells = []
var scale = Vector2(0.4, 0.4)

var tile1RockScene
var character

func _ready():
	setCamera()

	map = get_node("map")
	print(map.get_used_cells())
	
	prepareCellAnimations()
	storeMapCells()
	
	#showTile(Vector2(3,0))
	#showTile(Vector2(3,1), true)
	#showTile(Vector2(1,-1), true)
	#showTile(Vector2(0,0), true)
	
	var sorter = CellsSorter.new()
	mapCells.sort_custom(sorter, "sort")
	
	for cell in mapCells:
		print("------------")
		var cellPosition = map.map_to_world(cell.position)
		print(cellPosition)
						
		#var xx = Vector2(300, -(230/2))	
		
		var nodeRock = tile1RockScene.instance()
		add_child(nodeRock)
		#nodeRock.set_scale(scale)
		nodeRock.set_pos(cellPosition)
		nodeRock.set_z(cell.position.y)
		nodeRock.set_scale(Vector2(0.55, 0.55))
		nodeRock.get_node("area").connect("input_event", self, "_button_pressed", [nodeRock])
		print(nodeRock.get_z())
		#nodeRock.get_node("AnimationPlayer").play("Appear")
		
	initCharacter()
		
	set_process(true)
	#set_process_input(true)
	
func _button_pressed(viewport, event, shape, node):
	if(event.type == InputEvent.MOUSE_BUTTON && event.button_index == BUTTON_RIGHT && event.pressed == 0):
		print("viewport", viewport)
		print("event", event)
		print("shape", shape)
		print("node", node)
		
		character.moveTo(node.get_pos())

#func _input(event):
#	if(event.type == InputEvent.MOUSE_BUTTON && event.button_index == BUTTON_RIGHT):
#		print(event)
#		characterToPosition(event.pos)
		
func characterToPosition(pos): 
	print(pos)
	character.set_pos(pos)
	
func setCamera():
	var camera = get_node("camera")
	var zoom = camera.get_zoom()
	zoom[0] += 0.7
	zoom[1] += 0.7
	camera.set_zoom(zoom)
	
func hideCell(cell):
	map.set_cell(cell.x, cell.y, -1)
	
func storeMapCells():
	var cells = map.get_used_cells()
	
	for cell in cells:
		var cellIndex = map.get_cellv(cell)
		var tile = {
			"index": cellIndex,
			"position": cell,
			"worldPosition": map.map_to_world(cell)
		}

		mapCells.append(tile)
		
		#hideCell(cell)
		
func showTile(position, animation = false):
	for cell in mapCells:
		if cell.position == position:
			#map.set_cell(cell.position.x, cell.position.y, cell.index)
			
			if animation:
				print("------------")
				var cellPosition = map.map_to_world(cell.position)
				print(cellPosition)
								
				#var xx = Vector2(300, -(230/2))	
				
				cellPosition.x = cellPosition.x
				cellPosition.y = cellPosition.y
				
				var nodeRock = tile1RockScene.instance()
				add_child(nodeRock)
				#nodeRock.set_scale(scale)
				nodeRock.set_pos(cellPosition)
				#nodeRock.get_node("AnimationPlayer").play("Appear")
			else:
				map.set_cell(cell.position.x, cell.position.y, cell.index)
			
func prepareCellAnimations():
	tile1RockScene = load("res://tile1.tscn")
	
func initCharacter():
	var characterScene = load("res://character.tscn")
	
	character = characterScene.instance()
	add_child(character)
	
	character.set_pos(Vector2(1800, 300))
	character.set_z(10)
	
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