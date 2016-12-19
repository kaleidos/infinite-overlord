extends Node2D

var map
var mapCells = []

func _ready():
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
			map.set_cell(cell.position.x, cell.position.y, cell.index)
	
func _process(delta):
	map = get_node("map")
	print(map.get_used_cells())
	
	#hideCell(Vector2(2,3))
	
	storeMapCells()
	showTile(Vector2(2,3))
	
	#print(tiles)
	#print(map.get_used_cells())
	#print(map.get_cellv(Vector2(1, 0)))
	#map.set_cell(1, 0, -1) # clear