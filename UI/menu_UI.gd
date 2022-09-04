extends Control

signal start_game_button_pressed
signal settings_button_presed
signal records_button_pressed

func _on_start_game_button_pressed():
	self.visible = false
	emit_signal("start_game_button_pressed")


func _on_exit_game_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_select_level_ui_back_button_pressed():
	self.visible = true


func _on_records_pressed():
	self.visible = false
	emit_signal("records_button_pressed")


func _on_records_ui_back_button_pressed():
	self.visible = true
