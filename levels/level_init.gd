extends Node2D

var player_scene = preload("res://Player/Player.tscn")

onready var player_parent_node = $YSort
onready var spawn_positon = $YSort/player_spawn_position
onready var background = $background

func _ready():
	var player = player_scene.instance()
	player_parent_node.add_child(player)
	player.global_position = spawn_positon.global_position
	var width = background.region_rect.size[0]
	var height = background.region_rect.size[1]
	player.set_camera_sizes(width, height)
