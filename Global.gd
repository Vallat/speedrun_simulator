extends Node

signal level_finished
signal new_best_time(type)
signal level_reload

const FILE_PATH_CONFIG = "user://config.cfg"
const FILE_PATH_SCORES = "user://scores.cfg"
const FILE_PATH_SAVES = "user://savegame.save"

const LEVELS_AMOUNT = 2

var best_time: Dictionary = {}
var best_time_no_hits: Dictionary = {}
var full_completion_time: Dictionary = {}
var full_completion_time_no_hits: Dictionary = {}
var current_level: int = 1
var current_level_finished: bool = false

func _ready():
	for i in range(1, LEVELS_AMOUNT + 1):
		best_time[i-1] = 0.0
		best_time_no_hits[i-1] = 0.0
		full_completion_time[i-1] = 0.0
		full_completion_time_no_hits[i-1] = 0.0
	load_configs()
	load_game()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_game()
		save_configs()


func load_menu() -> void:
	var menu_file = load("res://levels/main_menu.tscn")
	get_tree().change_scene_to(menu_file)


func load_level(level_to_load: int) -> void:
	if level_to_load > LEVELS_AMOUNT:
		return
	var path = "res://levels/level_%s.tscn"
	var level_file = load(path % var2str(level_to_load))
	current_level = level_to_load
	_on_level_reload()
	get_tree().change_scene_to(level_file)


func reload_level() -> void:
	get_tree().reload_current_scene()
	emit_signal("level_reload")
	_on_level_reload()


func _on_level_reload():
	current_level_finished = false


func _on_level_finished_recived():
	current_level_finished = true
	emit_signal("level_finished")


func load_configs():
	var scores = ConfigFile.new()
	var error = scores.load_encrypted_pass(FILE_PATH_SCORES, OS.get_unique_id())
	if error != OK:
		return
	for i in range(1, LEVELS_AMOUNT + 1):
		best_time[i-1] = scores.get_value("best_free_run_time", var2str(i), 0.0)
		best_time_no_hits[i-1] = scores.get_value("best_free_run_time_no_hits", var2str(i), 0.0)
		full_completion_time[i-1] = scores.get_value("best_full_completion_time", var2str(i), 0.0)
		full_completion_time_no_hits[i-1] = scores.get_value("best_full_completion_time_no_hits", var2str(i), 0.0)


func save_configs():
	var scores = ConfigFile.new()
	for i in range(1, LEVELS_AMOUNT + 1):
		scores.set_value("best_free_run_time", var2str(i), best_time[i-1])
		scores.set_value("best_free_run_time_no_hits", var2str(i), best_time_no_hits[i-1])
		scores.set_value("best_full_completion_time", var2str(i), full_completion_time[i-1])
		scores.set_value("best_full_completion_time_no_hits", var2str(i), full_completion_time_no_hits[i-1])
	scores.save_encrypted_pass(FILE_PATH_SCORES, OS.get_unique_id())


func save_game():
	var save_game = File.new()
	save_game.open(FILE_PATH_SAVES, File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.filename.empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		var node_data = node.call("save")

		save_game.store_line(to_json(node_data))
	save_game.close()


func load_game():
	var save_game = File.new()
	if not save_game.file_exists(FILE_PATH_SAVES):
		return
	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open(FILE_PATH_SAVES, File.READ)

	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data = parse_json(save_game.get_line())
		if not node_data:
			break

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instance()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			self.set(i, node_data[i])

	save_game.close()


enum{
	BEST_TIME,
	BEST_TIME_NO_HITS,
	FULL_COMPL,
	FULL_COMPL_NO_HITS,
}

func update_best_time(new_time: float):
	var current_best_time = best_time[current_level-1] 
	if new_time > current_best_time and current_best_time != 0:
		return
	
	best_time[current_level-1] = new_time
	emit_signal("new_best_time", BEST_TIME)


func get_best_time(level = current_level) -> float: 
	return best_time[level-1]


func update_best_time_no_hits(new_time: float):
	var current_best_time = best_time_no_hits[current_level-1] 
	if new_time > current_best_time and current_best_time != 0:
		return
	
	best_time_no_hits[current_level-1] = new_time
	emit_signal("new_best_time", BEST_TIME_NO_HITS)


func get_best_time_no_hits() -> float: 
	return best_time_no_hits[current_level-1]


func update_full_completion_time(new_time: float):
	var current_best_time = full_completion_time[current_level-1] 
	if new_time > current_best_time and current_best_time != 0:
		return
	
	full_completion_time[current_level-1] = new_time
	emit_signal("new_best_time", FULL_COMPL)


func get_full_completion_time() -> float: 
	return full_completion_time[current_level-1]


func update_full_completion_time_no_hits(new_time: float):
	var current_best_time = full_completion_time_no_hits[current_level-1] 
	if new_time > current_best_time and current_best_time != 0:
		return
	
	full_completion_time_no_hits[current_level-1] = new_time
	emit_signal("new_best_time", FULL_COMPL_NO_HITS)


func get_full_completion_time_no_hits() -> float: 
	return full_completion_time_no_hits[current_level-1]

