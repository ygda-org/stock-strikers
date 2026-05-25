extends CharacterBody2D

signal hurt_player

const BULLET = preload("uid://ckwbgunr68qm")
@export var pig_speed: int
@export var bullet_speed: int
@export var kb_decel: float
@onready var timer: Timer = $Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $Anim
@onready var marker: Marker2D = $Marker2D

var is_knockback:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if GameState.player and !is_knockback:
		var distance = GameState.player.global_position - global_position  
		velocity = distance.normalized() * pig_speed
	if is_knockback:
		velocity = lerp(velocity, Vector2.ZERO, kb_decel * delta)
		is_knockback = !(velocity.length()>-10 and velocity.length()<10)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body.is_in_group("Player"):
			body.hurt(10)
			knockback(300)
			break
	move_and_slide()
	
	
func knockback(speed:int):
	if GameState.player and !is_knockback:
		velocity = (GameState.player.global_position - global_position).normalized() * speed * -1
		is_knockback = true

func _on_timer_timeout() -> void:
	if GameState.player and !is_knockback:
		var bullet = BULLET.instantiate()
		get_parent().add_child(bullet)
		var distance = GameState.player.global_position - global_position
		var offset = (marker.global_position - global_position).abs()
		bullet.velocity = distance.normalized() * bullet_speed
		bullet.global_position = global_position + (distance.normalized() * offset)
	
