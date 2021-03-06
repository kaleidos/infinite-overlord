extends Panel

var mainNode

func _ready():
	mainNode = root()
	set_fixed_process(true)
	
func _fixed_process(delta):
	setBuildPermissions()
	
func root():
	return get_tree().get_root().get_node("mainNode")	
	
func setBuildPermissions():
	var rootNode = root()
	var farm = get_node("Buildings/farm")
	var mine = get_node("Buildings/mine")
	var temple = get_node("Buildings/temple")
	
	mine.set_disabled(rootNode.totalResources.gold < rootNode.costs.mine)
	if rootNode.totalResources.gold < rootNode.costs.mine:
		mine.get_node("Label").set_text(str(rootNode.costs.mine - rootNode.totalResources.gold))
		mine.get_node("Label").show()
	else:
		mine.get_node("Label").hide()	
	
	farm.set_disabled(rootNode.totalResources.gold < rootNode.costs.farm)
	if rootNode.totalResources.gold < rootNode.costs.farm:
		farm.get_node("Label").set_text(str(rootNode.costs.farm - rootNode.totalResources.gold))
		farm.get_node("Label").show()
	else:
		farm.get_node("Label").hide()
		
	temple.set_disabled(rootNode.totalResources.gold < rootNode.costs.temple)
	if rootNode.totalResources.gold < rootNode.costs.temple:
		temple.get_node("Label").set_text(str(rootNode.costs.temple - rootNode.totalResources.gold))
		temple.get_node("Label").show()
	else:
		temple.get_node("Label").hide()		

func _on_Build_item_selected( index ):
	var build = get_node("Build")
	
	if build.is_item_disabled(index):
		return null
	
	build.hide()	
	get_node("ItemList").show()
	
	var mainNode = get_tree().get_root().get_node("mainNode")
	
	if index == 0:
		mainNode.prepareBuild("mine")
	elif index == 1:
		mainNode.prepareBuild("temple")
		
	get_node("Build").unselect(index)

func _on_BuildBtn_button_up():
	get_node("Buildings").show()
	get_node("BuildBtn").hide()

func _on_farm_button_up():
	mainNode.prepareBuild("farm")

func _on_mine_button_up():
	mainNode.prepareBuild("mine")

func _on_temple_button_up():
	mainNode.prepareBuild("temple")

func _on_exit_button_up():
	get_node("Buildings").hide()
	get_node("BuildBtn").show()
