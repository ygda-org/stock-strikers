extends CharacterBody2D

const BULLET = preload("uid://elmhj6ii3asu")
@export var pig_speed: int
@export var bullet_speed: int
@export var bullet_damage: int

@onready var timer: Timer = $Timer
@onready var animation: AnimatedSprite2D = $Anim
@onready var marker: Marker2D = $Marker2D
@onready var enemy_component = $EnemyComponent
var rng = RandomNumberGenerator.new()

var barrage_times := 5
var regular_times := 3
var times := 0
var is_stopped := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("side")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if GameState.player and !enemy_component.is_stunned and !is_stopped:
		var distance = GameState.player.global_position - global_position  
		velocity = distance.normalized() * pig_speed
		choose_anim(velocity)
	if is_stopped:
		velocity = Vector2.ZERO
	var collisions = [] # need these 4 lines in every enemy's physics process
	for i in get_slide_collision_count():
		collisions.append(get_slide_collision(i))
	enemy_component.process_collisions(collisions)
	move_and_slide()
	
func shoot(target):
	var bullet = BULLET.instantiate()
	get_parent().add_child(bullet)
	var bul_distance = target - marker.global_position
	var bul_position = marker.global_position
	bullet.initialize(bul_distance,bul_position,bullet_damage)
	bullet.target = target
	
func choose_anim(vel:Vector2):
	var current_frame = animation.get_frame()
	var current_progress = animation.get_frame_progress()
	if vel.angle() > (3*PI)/4 or vel.angle() < -(3*PI)/4:
		if not animation.animation == "side":
			animation.play("side")
		animation.flip_h = false
		animation.set_frame_and_progress(current_frame, current_progress)
		return
	if vel.angle() < (3*PI)/4 and vel.angle() < -PI/4:
		if not animation.animation == "back":
			animation.play("back")
		animation.flip_h = false
		animation.set_frame_and_progress(current_frame, current_progress)
		return
	if vel.angle() < (PI)/4 and vel.angle() > -PI/4:
		if not animation.animation == "side":
			animation.play("side")
		animation.flip_h = true
		animation.set_frame_and_progress(current_frame, current_progress)
		return
	if vel.angle() > PI/4 and vel.angle() < (3*PI)/4:
		if not animation.animation == "front":
			animation.play("front")
		animation.flip_h = false
		animation.set_frame_and_progress(current_frame, current_progress)
		return

#func _on_timer_timeout() -> void:
	#if GameState.player and times < 3:
		#shoot(GameState.player.global_position)
		#times += 1
		#timer.start()
		#return
	#if GameState.player and times >= regular_times:
		#shoot(GameState.player.global_position)
		#await get_tree().create_timer(0.3).timeout
		#for i in barrage_times:
			#shoot(GameState.player.global_position + Vector2(rng.randf_range(-30,30),rng.randf_range(-30,30)))
			#await get_tree().create_timer(0.3).timeout
		#times = 0
		#timer.start()
		#return


func _on_anim_frame_changed() -> void:
	if animation.animation == "charge":
		if animation.frame == 5 and times < barrage_times:
			shoot(GameState.player.global_position + Vector2(rng.randf_range(-30,30),rng.randf_range(-30,30)))
			animation.set_frame_and_progress(2,0)
			times += 1
		if animation.frame == 8 and times >= barrage_times:
			times = 0 
			animation.play("front")
			is_stopped = false
		return
	if animation.frame == 2:
		shoot(GameState.player.global_position)
		times += 1
		if (times >= regular_times):
			times = 0
			await get_tree().create_timer(0.1).timeout
			is_stopped = true
			animation.play("charge")
	
