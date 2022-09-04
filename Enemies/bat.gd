extends KinematicBody2D

export(int) var KNOCKBACK_SPEED = 250
export(int) var KNOCKBACK_FRICTION = 25
var knockback = Vector2.ZERO

export(int) var ACCELERATION = 10
export(int) var FRICTION = 5
export(int) var MAX_SPEED = 100
var velocity = Vector2.ZERO
var level_finished: bool = false

const death_effect_scene = preload("res://Effects/bat_death_effect.tscn")

onready var stats = $stats
onready var sprite = $main_sprite
onready var detection_zone = $player_detection_zone
onready var soft_collision = $SoftCollision
onready var wander_controller = $WandererController
onready var hitbox = $hitbox
onready var hurtbox = $hurtbox

enum {
	IDLE,
	WANDER,
	CHASE
}

var current_state = WANDER

func _ready():
	add_to_group("enemies")
	Global.connect("level_finished", self, "_on_level_finished")


func _physics_process(delta):
	if level_finished:
		return

	handle_knockback(delta)

	match current_state:
		IDLE:
			handle_idle_state(delta)
			handle_random_state()
		WANDER:
			handle_wander_state(delta)
			handle_random_state()
		CHASE:
			handle_chase_state(delta)

	sprite.flip_h = velocity.x < 0
	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector() * delta * MAX_SPEED * ACCELERATION
	
	velocity = move_and_slide(velocity)


func handle_knockback(delta):
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * 60 * delta)
	knockback = move_and_slide(knockback)


func handle_random_state():
	if wander_controller.get_time_left() == 0:
		current_state = pick_random_state([IDLE, WANDER])
		wander_controller.start_wander_timer(rand_range(1, 3))


func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()


func handle_idle_state(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * 60 * delta)
	seek_for_player()


func handle_wander_state(delta):
	seek_for_player()

	var vector_to_move = global_position.direction_to(wander_controller.target_position)
	velocity = velocity.move_toward(vector_to_move * MAX_SPEED, ACCELERATION * 60 * delta)

	if global_position.distance_to(wander_controller.target_position) <= MAX_SPEED * delta:
		current_state = pick_random_state([IDLE, WANDER])
		wander_controller.start_wander_timer(rand_range(1, 3))


func handle_chase_state(delta):
	if(!detection_zone.can_see_player()):
		current_state = IDLE
		return

	var player = detection_zone.player
	var vector_to_move = global_position.direction_to(player.global_position)
	velocity = velocity.move_toward(vector_to_move * MAX_SPEED, ACCELERATION * 60 * delta)
	

func seek_for_player():
	if(!detection_zone.can_see_player()):
		return
	current_state = CHASE 


func _on_hurtbox_area_entered(area):
	stats.decrease_health(area.damage)
	hurtbox.start_invincibility(0.3)
	knockback = area.knockback_vector * KNOCKBACK_SPEED


func _on_stats_no_health():
	on_death()


func on_death():
	var death_effect = death_effect_scene.instance()
	get_parent().add_child(death_effect)
	death_effect.position = self.position
	queue_free()


func _on_level_finished() -> void:
	level_finished = true
	hitbox.set_deferred("monitorable", false)
	hurtbox.set_deferred("monitoring", false)
