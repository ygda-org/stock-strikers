extends CharacterBody2D

signal death_anim_complete

var wallet_speed: int = 50
var bullet_speed: int = 100
var bullet_damage: int = 25

@onready var animation:AnimatedSprite2D = $Anim
@onready var enemy_component = $EnemyComponent
@onready var hurtbox:CollisionShape2D = $CollisionShape2D

const BULLET = preload("uid://b3rg1vs3nw1es")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if GameState.player and !enemy_component.is_stunned and enemy_component.is_alive:
		velocity = (GameState.player.global_position - global_position).normalized() * wallet_speed
	var collisions = [] # need these 4 lines in every enemy's physics process
	for i in get_slide_collision_count():
		collisions.append(get_slide_collision(i))
	enemy_component.process_collisions(collisions)
	move_and_slide()
	if !enemy_component.is_stunned and enemy_component.is_alive:
		choose_anim(velocity)

func choose_anim(vel:Vector2):
	if vel.angle() > (3*PI)/4 or vel.angle() < -(3*PI)/4:
		if not animation.animation == "side":
			animation.play("side")
		animation.flip_h = false
		return
	if vel.angle() < PI/4 and vel.angle() > -PI/4:
		if not animation.animation == "side":
			animation.play("side")
		animation.flip_h = true
		return
	if vel.angle() < -PI/4 and vel.angle() > -(3*PI)/4:
		if not animation.animation == "back":
			animation.play("back")
		animation.flip_h = false
		return
	if vel.angle() > PI/4 and vel.angle() < (3*PI)/4:
		if not animation.animation == "front":
			animation.play("front")
		animation.flip_h = false
		return

func die():
	hurtbox.disabled = true
	enemy_component.is_stunned = true
	animation.play("death")
	animation.flip_h = false
	await animation.animation_finished
	death_anim_complete.emit()
	return

func shoot():
	if GameState.player:
		var bullet = BULLET.instantiate()
		var distance = GameState.player.global_position - global_position
		get_parent().add_child(bullet)
		bullet.global_position = global_position
		bullet.global_rotation = distance.angle() + PI/2
		bullet.damage = bullet_damage
		bullet.initialize(distance.normalized() * bullet_speed)

func _on_timer_timeout() -> void:
	shoot()
