extends Area2D

signal level_finished


func _ready():
	connect("level_finished", Global, "_on_level_finished_recived")

func _on_game_finish_body_entered(body: Player):
	if not body:
		return
	emit_signal("level_finished")
