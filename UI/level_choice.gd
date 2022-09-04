extends Button

signal level_to_load_chosen(level_num)


export(int) var level_to_load = 1
 

func _ready():
	self.text = "Level " + var2str(level_to_load)
	connect("pressed", self, "_on_level_choice_pressed")


func _on_level_choice_pressed():
	emit_signal("level_to_load_chosen", level_to_load)
