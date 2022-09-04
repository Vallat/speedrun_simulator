extends Label

func _physics_process(delta):
	var enemies = get_tree().get_nodes_in_group("enemies")
	text = "Enemies: " + var2str(enemies.size())
