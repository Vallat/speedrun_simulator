extends Control

var max_hearts = 3 setget set_max_hearts
var hearts = 3 setget set_hearts

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty

func set_max_hearts(value):
	max_hearts = value
	if heartUIEmpty:
		heartUIEmpty.rect_size.x = max_hearts * 15

func set_hearts(value):
	hearts = value
	if heartUIFull:
		heartUIFull.rect_size.x = hearts * 15

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("health_changed", self, "health_changed")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")

func health_changed(old_health, new_health):
	set_hearts(new_health)
