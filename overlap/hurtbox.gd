extends Area2D

signal invincibility_started
signal invincibility_ended

export(bool) var show_hit = true

var hit_effect = null
var invincible: bool = false setget set_invincible

onready var timer = $Timer

func _ready():
	if(show_hit):
		hit_effect = preload("res://Effects/hit_effect.tscn")
		connect("area_entered", self, "_create_hit_effect")

func _create_hit_effect(area):
	var effect = hit_effect.instance()
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position

func set_invincible(value: bool):
	invincible = value
	set_deferred("monitoring", !invincible)
	if invincible:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration: float = 1.0):
	self.invincible = true
	timer.start(duration)

func _on_Timer_timeout():
	self.invincible = false
