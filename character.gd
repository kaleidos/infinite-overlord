extends Node2D

var walkspeed = 200
var targetPosition
var body
var moving = false

func _ready():
	body = get_node("body")
	set_fixed_process(true)

func _fixed_process(delta):
	if body.get_pos() == targetPosition:
		moving = false
	
	if moving:
		var direction = (targetPosition - body.get_pos()).normalized()
		print(direction)
		var motion = direction * walkspeed * delta
		body.move(motion)

func moveTo(_destination_):
	targetPosition = _destination_
	print(body.get_pos())
	print(targetPosition)
	print(targetPosition - body.get_pos())
	#moving = true