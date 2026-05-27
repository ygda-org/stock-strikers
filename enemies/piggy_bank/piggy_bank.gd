extends CharacterBody2D

signal hurt_player

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



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("hop")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if GameState.player and !enemy_component.is_stunned:
		var distance = GameState.player.global_position - global_position  
		velocity = distance.normalized() * pig_speed
	var collisions = [] # need these 4 lines in every enemy's physics process
	for i in get_slide_collision_count():
		collisions.append(get_slide_collision(i))
	enemy_component.process_collisions(collisions)
	move_and_slide()
	choose_anim(velocity)
	
func shoot(target):
	var bullet = BULLET.instantiate()
	get_parent().add_child(bullet)
	var bul_distance = target - marker.global_position
	var bul_position = marker.global_position
	bullet.initialize(bul_distance,bul_position,bullet_damage)
	bullet.target = target
	
func choose_anim(vel:Vector2):
	if vel.angle() > PI/2 or vel.angle() < -PI/2:
		if not animation.animation == "hop":
			animation.play("hop")
		animation.flip_h = false
		return
	if vel.angle() < PI/2 or vel.angle() > -PI/2:
		if not animation.animation == "hop":
			animation.play("hop")
		animation.flip_h = true
		return
	
func _on_timer_timeout() -> void:
	if GameState.player and times < 3:
		shoot(GameState.player.global_position)
		times += 1
		timer.start()
		return
	if GameState.player and times >= regular_times:
		shoot(GameState.player.global_position)
		await get_tree().create_timer(0.3).timeout
		for i in barrage_times:
			shoot(GameState.player.global_position + Vector2(rng.randf_range(-30,30),rng.randf_range(-30,30)))
			await get_tree().create_timer(0.3).timeout
		times = 0
		timer.start()
		return
