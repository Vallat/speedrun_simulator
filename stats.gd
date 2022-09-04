extends Node

signal no_health
signal health_changed(old_health, new_health)
signal max_health_changed

export(int) var max_health = 1 setget set_max_health
var health = 0 setget set_health

func _ready():
	health = max_health

func set_health(value):
	var old_value = health
	health = min(value, max_health)
	emit_signal("health_changed", old_value, health)
	check_health()

func set_max_health(value):
	max_health = max(1, value)
	self.health = min(health, max_health)
	emit_signal("max_health_changed", value)

func decrease_health(amount: int = 1):
	self.health -= amount

func increase_health(amount: int = 1):
	self.health += amount

func is_max_health() -> bool:
	return health == max_health

func check_health():
	if(health <= 0):
		emit_signal("no_health")
