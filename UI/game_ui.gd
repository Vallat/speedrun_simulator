extends CanvasLayer

onready var hits_taken_label = $hits_taken
onready var timer = $timer


func _ready():
	visible = true


func set_hits_taken(value: int) -> void:
	hits_taken_label.text = var2str(value)
	timer.set_got_hit(true)
