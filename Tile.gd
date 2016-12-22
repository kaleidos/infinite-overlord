extends Node2D
	
func root():
	return get_tree().get_root().get_node("mainNode")
	
func addStructure(type):	
	var rootNode = root()
	if self.resource != null:
		self.remove_child(self.get_node(self.resource))

	self.structure = type
	var structureNode = root().tilesTypes.structures[type].instance()
	structureNode.set_z(9)
	self.add_child(structureNode)
	
	root().structure[type] += 1
	
	if structureNode.has_node("AnimationPlayer"):
		structureNode.get_node("AnimationPlayer").play("standard_structure_appear")
	
	rootNode.bought(type)
	
func addResource(type):	
	self.resource = type
	var resourceNode = root().tilesTypes.resources[type].instance()
	resourceNode.set_z(9)
	self.add_child(resourceNode)
	
	if resourceNode.has_node("AnimationPlayer"):
		resourceNode.get_node("AnimationPlayer").play("standard_structure_appear")

func hasResource(_resource_):
	return _resource_ == self.resource 
	
func hasStructure(_structure_):
	return _structure_ == self.structure