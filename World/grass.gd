extends Node2D

const grass_effect_scene = preload("res://Effects/grass_effect.tscn")

func _on_hurtbox_area_entered(area):
	create_destroy_effect()
	on_destroy()

func create_destroy_effect():
	var grass_effect = grass_effect_scene.instance()
	get_parent().add_child(grass_effect)
	grass_effect.position = self.position

func on_destroy():
	queue_free()
