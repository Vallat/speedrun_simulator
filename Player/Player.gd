extends KinematicBody2D

class_name Player

export(int) var ACCELERATION = 10
export(int) var FRICTION = 10
export(int) var MAX_SPEED = 100
export(int) var ROLL_SPEED = 150
export(int) var ROLL_COOLDOWN = 0.5

enum {
	MOVE,
	ROLL,
	ATTACK,
	ATTACK_END,
}

var state = MOVE
var input_vector = Vector2.ZERO
var attack_vector = Vector2.DOWN
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats
var roll_oncooldown: bool = false
var hits_taken = 0
var level_finished: bool = false

onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var sword_hitbox = $hitbox_pivot/sword_hitbox
onready var hurtbox = $hurtbox
onready var timer = $Timer
onready var game_ui = $game_ui
onready var camera = $Camera2D


func _ready():
	stats.connect("no_health", self, "on_death")
	Global.connect("level_finished", self, "_on_level_finished")
	Global.connect("level_reload", self, "_on_global_reload_level")
	animation_tree.active = true
	sword_hitbox.knockback_vector = roll_vector
	level_finished = false
	stats.increase_health(100)
	yield(get_tree().create_timer(0.1), "timeout")
	camera.smoothing_enabled = true

func _physics_process(delta):
	if level_finished:
		return
	handle_input(delta)
	match (state):
		MOVE:
			handle_move(delta)
		ROLL:
			handle_roll(delta)
		ATTACK, ATTACK_END:
			handle_attack(delta)

func handle_input(_delta):
	input_vector.x = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	input_vector.y = (Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		if state != ROLL:
			roll_vector = input_vector
		if state != ATTACK and state != ATTACK_END:
			attack_vector = input_vector
			sword_hitbox.knockback_vector = attack_vector
			animation_tree.set("parameters/Attack/blend_position", attack_vector)

	if Input.is_action_just_pressed("reload"):
		Global.reload_level()
		return

	match state:
		MOVE:
			if Input.is_action_pressed("attack"):
				state = ATTACK
				do_attack()
			else:
				continue
		MOVE, ATTACK_END:
			if !roll_oncooldown and Input.is_action_pressed("space"):
				state = ROLL
				do_roll()


func handle_move(delta):
	if input_vector != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		animation_state.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * 60 * delta)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * 60 * delta)
	velocity = move_and_slide(velocity)


func do_attack():
	attack_vector = global_position.direction_to(get_global_mouse_position()).normalized()
	sword_hitbox.knockback_vector = attack_vector
	if attack_vector != Vector2.ZERO:
		animation_tree.set("parameters/Attack/blend_position", attack_vector)
		animation_tree.set("parameters/Idle/blend_position", attack_vector)
	animation_state.travel("Attack")


func handle_attack(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * 60 * delta)
	velocity = move_and_slide(velocity)


func do_roll():
	if input_vector != Vector2.ZERO:
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		animation_tree.set("parameters/Idle/blend_position", input_vector)
	animation_state.travel("Roll")
	hurtbox.set_invincible(true)


func handle_roll(delta):
	velocity = move_and_slide(roll_vector * ROLL_SPEED)


func roll_animation_finished():
	state = MOVE
	hurtbox.set_invincible(false)
	roll_oncooldown = true
	timer.start(ROLL_COOLDOWN)


func attack_animation_almost_finished():
	state = ATTACK_END


func attack_animation_finished():
	state = MOVE


func on_death():
	Global.reload_level()


func _on_global_reload_level():
	stats.increase_health(100)


func increase_health(amount: int) -> void:
	stats.increase_health(amount)


func decrease_health(amount: int) -> void:
	stats.decrease_health(amount)


func is_full_health() -> bool:
	return stats.is_max_health()


func _on_hurtbox_area_entered(area):
	decrease_health(1)
	hits_taken += 1
	game_ui.set_hits_taken(hits_taken)
	hurtbox.start_invincibility(0.5)
	play_hit_sound()


var hit_sound = preload("res://Music and Sounds/player_hit_sound.tscn")
func play_hit_sound():
	var sound_to_play = hit_sound.instance()
	get_tree().current_scene.add_child(sound_to_play)


onready var music_player = $music_player
func _on_music_player_finished():
	music_player.play()


func _on_Timer_timeout():
	roll_oncooldown = false


func set_camera_sizes(level_x_size: int, level_y_size: int) -> void:
	camera.limit_right = level_x_size / 2
	camera.limit_left = -camera.limit_right

	camera.limit_bottom = level_y_size / 2
	camera.limit_top = -camera.limit_bottom


func _on_level_finished():
	level_finished = true
