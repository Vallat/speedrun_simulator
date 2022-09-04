extends Area2D

onready var timer = $cooldown_timer

var player = null


func can_see_player():
	return player != null


func player_found(body):
	player = body


func player_lost(body):
	if not body:
		return
	if overlaps_body(body):
		return
	player = null


func _on_player_detection_zone_body_entered(body):
	player_found(body)


func _on_player_detection_zone_body_exited(body):
	if get_parent().is_queued_for_deletion():
		return
	timer.start(3)


func _on_Timer_timeout():
	player_lost(player)
