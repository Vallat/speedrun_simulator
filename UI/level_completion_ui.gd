extends Control

onready var next_level = $next_level
onready var end_message = $end_message
onready var new_record_message = $new_record_message


func _ready():
	self.visible = false
	Global.connect("level_finished", self, "on_level_finish")
	Global.connect("new_best_time", self, "new_best_time")


func on_level_finish() -> void:
	self.visible = true
	if Global.current_level + 1 > Global.LEVELS_AMOUNT:
		next_level.disabled = true
	end_message.text = "Level complete!"


func new_best_time(type) -> void:
	var message
	match type:
		Global.BEST_TIME:
			message = "New best time record!"
		Global.BEST_TIME_NO_HITS:
			message = "New no hits record!"
		Global.FULL_COMPL:
			message = "New full run record!"
		Global.FULL_COMPL_NO_HITS:
			message = "New full run with no hits record!"
	new_record_message.text = message

func _on_next_level_pressed():
	Global.load_level(Global.current_level + 1)


func _on_main_menu_pressed():
	Global.load_menu()


func _on_play_again_pressed():
	Global.reload_level()
