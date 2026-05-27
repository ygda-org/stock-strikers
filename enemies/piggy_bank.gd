extends CharacterBody2D

signal hurt_player

const BULLET = preload("uid://elmhj6ii3asu")
@export var pig_speed: int
@export var bullet_speed: int
@export var bullet_damage: int
@export var kb_decel: float
@onready var timer: Timer = $Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $Anim
@onready var marker: Marker2D = $Marker2D
@onready var health_bar: ProgressBar = $HealthBar
var rng = RandomNumberGenerator.new()
var max_health := 30
var barrage_times := 5
var regular_times := 3
var times := 0
var current_health := 30
var is_knockback:bool = false
var is_stunned:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()
	animated_sprite_2d.play("hop")
	health_bar.max_value = max_health
	health_bar.value = current_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if current_health <= 0:
		die()
	if GameState.player and !is_stunned:
		var distance = GameState.player.global_position - global_position  
		velocity = distance.normalized() * pig_speed
	if is_knockback:
		velocity = lerp(velocity, Vector2.ZERO, kb_decel * delta)
		if (velocity.length()>-10 and velocity.length()<10):
			is_knockback = false
			is_stunned = false
			animated_sprite_2d.play("hop")
	var player_got_hit = false
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body.is_in_group("Player") and !player_got_hit:
			body.hurt(10)
			knockback(body,300)
			player_got_hit = true
	move_and_slide()
	
	
func knockback(object,speed:int):
	if !is_knockback:
		velocity = (object.global_position - global_position).normalized() * speed * -1
		is_knockback = true
		is_stunned = true
		animated_sprite_2d.stop()
func hurt(health):
	current_health -= health
	health_bar.value = current_health

func die():
	is_stunned = true
	queue_free()
func shoot(target):
	var bullet = BULLET.instantiate()
	get_parent().add_child(bullet)
	var bul_distance = target - marker.global_position
	var bul_position = marker.global_position
	bullet.initialize(bul_distance,bul_position,bullet_damage)
	bullet.target = target
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
	
