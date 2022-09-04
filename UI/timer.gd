extends Control

var timer_on: bool = false
var time = 0
var got_hit: bool = false

onready var current_timer = $current_timer
onready var best_time = $best_time

func _ready():
	Global.connect("level_finished", self, "toggle_timer_off")
	var last_num = 6 if time >= 10 else 5
	best_time.text = var2str(Global.get_best_time()).substr(0, last_num)


func _physics_process(delta):
	if not timer_on:
		handle_input()
		return
	time += delta
	var last_num = 6 if time >= 10 else 5
	current_timer.text = var2str(time).substr(0, last_num)
	var current_best_time = Global.get_best_time()
	if current_best_time == 0 or current_best_time > time:
		return
	current_timer.set_deferred("custom_colors/font_color", "#ff0000")


func handle_input():
	if Global.current_level_finished:
		return
	if(
		Input.is_action_pressed("space")
		or Input.is_action_pressed("move_down")
		or Input.is_action_pressed("move_up")
		or Input.is_action_pressed("move_left")
		or Input.is_action_pressed("move_right")
	):
		toggle_timer_on()


func toggle_timer_off():
	timer_on = false
	update_best_time()


func toggle_timer_on():
	timer_on = true


func update_best_time() -> void:
	Global.update_best_time(time)
	if not got_hit:
		Global.update_best_time_no_hits(time)

	var enemies = get_tree().get_nodes_in_group("enemies")
	var enemies_amount = enemies.size()
	if not enemies_amount:
		Global.update_full_completion_time(time)
		if not got_hit:
			Global.update_full_completion_time_no_hits(time)

	var last_num = 6 if time >= 10 else 5
	best_time.text = var2str(Global.get_best_time()).substr(0, last_num)


func set_got_hit(value: bool) -> void:
	got_hit = value
