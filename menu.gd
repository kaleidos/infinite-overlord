extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_fixed_process(true)
	setItemList()
	
func _fixed_process(delta):
	setBuildPermissions()
	
func root():
	return get_tree().get_root().get_node("mainNode")	
	
func setItemList():
	var rootNode = root()
	
	get_node("ItemList").add_item("Build")
	
	var build = get_node("Build")
	build.add_item(str("Mine (", rootNode.costs.mine, ")"))
	build.add_item(str("Temple (", rootNode.costs.temple , ")"))
	
func setBuildPermissions():
	var rootNode = root()
	var build = get_node("Build")
	
	if (rootNode.totalResources.gold >= rootNode.costs.mine):
		build.set_item_disabled(0, false)
	else:
		build.set_item_disabled(0, true)
		
	if (rootNode.totalResources.gold >= rootNode.costs.temple):
		build.set_item_disabled(1, false)
	else:
		build.set_item_disabled(1, true)		

func _on_ItemList_item_selected( index ):
	print(index)
	if index == 0:
		get_node("ItemList").hide()
		get_node("Build").show()
		
	get_node("ItemList").unselect(index)

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
