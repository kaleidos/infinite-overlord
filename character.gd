extends KinematicBody2D

var walkspeed = 400
var targetPosition
var path
var moving = false
var cube
var cubePath
var lastStructure
var lastResource

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if moving && (get_pos() - targetPosition).length() <= 10:
		nextPosition()
	
	if moving:
		var direction = (targetPosition - get_pos()).normalized()
		var motion = direction * walkspeed * delta
		move(motion)

func nextPosition():
	var root = get_tree().get_root().get_node("mainNode")
	
	if (lastStructure != null):
		lastStructure.set_opacity(1)
		
	if (lastResource != null):
		lastResource.set_opacity(1)
		
	if !path.empty():
		root.cleanSelectedNodes()
		
		targetPosition = path[0]
		path.pop_front()	
		moving = true
		if (targetPosition <= get_pos()):
		    get_node("Sprite").set_flip_h(false)
		else:
			get_node("Sprite").set_flip_h(true)
		get_node("Sprite").play("forward_left")
	else:
		moving = false
		get_node("Sprite").stop()
		get_node("Sprite").set_animation("stop")
		
		root.hidePath(cubePath)
		
		refreshOverlap()
		
	get_tree().get_root().get_node("mainNode").showAdjacentTilesByCords(targetPosition)

func refreshOverlap():
	var neighbors = get_tree().get_root().get_node("mainNode").neighbors(cube)
		
	if (neighbors.bottom != null && neighbors.bottom.node.structure != null):
		lastStructure = neighbors.bottom.node.get_node(neighbors.bottom.node.structure)
		lastStructure.set_opacity(0.5)
		
	if (neighbors.bottom != null && neighbors.bottom.node.resource != null):
		lastResource = neighbors.bottom.node.get_node(neighbors.bottom.node.resource)
		lastResource.set_opacity(0.5)
			
func moveTo(_path_, _cubePath_):
	path = _path_
	cubePath = []
	cubePath = [] + _cubePath_
	
	nextPosition()