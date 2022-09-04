extends Control

signal back_button_pressed

onready var flow_container = $scroll_container/flow_container
var records_ui_row_file = preload("res://UI/records_ui_row.tscn")

func _ready():
	self.visible = false
	for i in range(1, Global.LEVELS_AMOUNT + 1):
		var records_row = records_ui_row_file.instance()
		flow_container.add_child(records_row)
		records_row.set_level_name(var2str(i))
		records_row.set_best_score(var2str(Global.best_time[i-1]))
		records_row.set_best_full(var2str(Global.full_completion_time[i-1]))
		records_row.set_best_score_nh(var2str(Global.best_time_no_hits[i-1]))
		records_row.set_best_full_nh(var2str(Global.full_completion_time_no_hits[i-1]))


func _on_go_back_pressed():
	self.visible = false
	emit_signal("back_button_pressed")


func _on_menu_UI_records_button_pressed():
	self.visible = true
