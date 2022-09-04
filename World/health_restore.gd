extends Sprite

onready var area = $Area2D

func _on_Area2D_body_entered(body: Player) -> void:
	if not Player:
		return

	if body.is_full_health():
		return

	body.increase_health(1)
	play_sound()
	queue_free()


var pickup_sound = preload("res://Music and Sounds/health_increase_sound.tscn")
func play_sound():
	var sound_to_play = pickup_sound.instance()
	get_tree().current_scene.add_child(sound_to_play)
