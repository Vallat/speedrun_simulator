extends Control

onready var level_name = $level_name
onready var best_score = $best_score
onready var best_full = $best_full
onready var best_score_nh = $best_score_nh
onready var best_full_nh = $best_full_nh

func set_level_name(new_name: String) -> void:
	self.level_name.text = new_name

func set_best_score(new_name: String) -> void:
	self.best_score.text = new_name

func set_best_full(new_name: String) -> void:
	self.best_full.text = new_name

func set_best_score_nh(new_name: String) -> void:
	self.best_score_nh.text = new_name

func set_best_full_nh(new_name: String) -> void:
	self.best_full_nh.text = new_name
