extends Node2D

var elapsed = 0
var time = 1000
var destination
var moving = false
var start

func _ready():
	set_process(true)

func _process(delta):
	if !moving:
		return
	
	if elapsed >= time:
		set_pos(destination)
		return
		
	elapsed += delta
	var intermediate =  (destination-start) / (elapsed / time) + start
	set_pos(intermediate)

func moveTo(_destination_):
	moving = true
	destination = _destination_