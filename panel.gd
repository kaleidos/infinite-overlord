extends Panel

var _timer = null

func root():
	return get_tree().get_root().get_node("mainNode")

func _ready():
    _timer = Timer.new()
    add_child(_timer)

    _timer.connect("timeout", self, "_on_Timer_timeout")
    _timer.set_wait_time(1.0)
    _timer.set_one_shot(false)
    _timer.start()


func _on_Timer_timeout():
	var root = root()
	root.totalResources.gold += root.structure.mine
	root.totalResources.experience += root.structure.temple
	
	print(root.totalResources.gold, " Gold")
	print(root.totalResources.experience, " Experience")