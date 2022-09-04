extends Control


func _ready():
	self.visible = false


func _input(event):
	if not event.is_action_pressed("pause_menu"):
		return

	if get_tree().paused:
		unpause_game()
	else:
		pause_game()


func pause_game():
	self.visible = true
	get_tree().paused = true


func unpause_game():
	self.visible = false
	get_tree().paused = false


func _on_continue_pressed():
	unpause_game()


func _on_main_menu_pressed():
	unpause_game()
	Global.load_menu()


func _on_play_again_pressed():
	unpause_game()
	Global.reload_level()
