extends Node2D

var map
var mapCells = []
var scale = Vector2(1, 1)

var tile1RockScene

func _ready():
	map = get_node("map")
	print(map.get_used_cells())
	
	prepareCellAnimations()
	storeMapCells()
	
	showTile(Vector2(3,0))
	showTile(Vector2(3,1), true)
	showTile(Vector2(1,-1), true)
	showTile(Vector2(0,0), true)
	
	set_process(true)
	
func hideCell(cell):
	map.set_cell(cell.x, cell.y, -1)
	
func storeMapCells():
	var cells = map.get_used_cells()
	
	for cell in cells:
		var cellIndex = map.get_cellv(cell)
		var tile = {
			"index": cellIndex,
			"position": cell
		}

		mapCells.append(tile)
		
		hideCell(cell)
		
func showTile(position, animation = false):
	for cell in mapCells:
		if cell.position == position:
			#map.set_cell(cell.position.x, cell.position.y, cell.index)
			
			if animation:
				print("------------")
				var cellPosition = map.map_to_world(cell.position)
				print(cellPosition)
								
				#var xx = Vector2(300, -(230/2))	
				
				cellPosition.x = cellPosition.x * scale.x
				cellPosition.y = cellPosition.y * scale.y
				
				var nodeRock = tile1RockScene.instance()
				add_child(nodeRock)
				nodeRock.set_scale(scale)
				nodeRock.set_pos(cellPosition)
				#nodeRock.get_node("AnimationPlayer").play("Appear")
			else:
				map.set_cell(cell.position.x, cell.position.y, cell.index)
			
func prepareCellAnimations():
	tile1RockScene = load("res://tile1.tscn")
	
func _process(delta):

	#print(tiles)
	#print(map.get_used_cells())
	#print(map.get_cellv(Vector2(1, 0)))
	#map.set_cell(1, 0, -1) # clear

	#var xx = Vector2(300, 570)	
	var xx = Vector2(300, -(230/2))	

	#nodeRock.set_pos(xx)
	#nodeRock.show()	