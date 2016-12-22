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
	root.totalResources.food += root.structure.farm
	
	get_node("label-gold").set_text(str(root.totalResources.gold, " (x", root.structure.mine, ")"))
	get_node("label-experience").set_text(str(root.totalResources.experience, " (x", root.structure.temple, ")"))
	get_node("label-food").set_text(str(root.totalResources.food, " (x", root.structure.farm, ")"))