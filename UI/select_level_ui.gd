extends Control

signal back_button_pressed

onready var flow_container = $scroll_container/flow_container

var level_choice_button = preload("res://UI/level_choice.tscn")

func _ready():
	self.visible = false
	for i in range(1, Global.LEVELS_AMOUNT + 1):
		var choice_button = level_choice_button.instance()
		choice_button.level_to_load = i
#		if i != 1 and Global.get_best_time(i) == 0:
#			choice_button.disabled = true
		flow_container.add_child(choice_button)
		choice_button.connect("level_to_load_chosen", self, "_on_level_choice_level_to_load_chosen")


func _on_level_choice_level_to_load_chosen(level_num: int) -> void:
	Global.load_level(level_num)


func _on_go_back_pressed():
	self.visible = false
	emit_signal("back_button_pressed")


func _on_menu_UI_start_game_button_pressed():
	self.visible = true
