extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	setItemList()
	
func setItemList():
	get_node("ItemList").add_item("Build")
	
	var build = get_node("Build")
	build.add_item("Mine")

func _on_ItemList_item_selected( index ):
	if index == 0:
		get_node("ItemList").hide()
		get_node("Build").show()


func _on_Build_item_selected( index ):
	get_node("ItemList").show()
	get_node("Build").hide()	
	
	if index == 0:
		get_tree().get_root().get_node("mainNode").prepareBuild("mine")
