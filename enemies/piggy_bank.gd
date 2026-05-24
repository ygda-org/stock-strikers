extends CharacterBody2D

const BULLET = preload("uid://ckwbgunr68qm")
@export var pig_speed: int
@export var bullet_speed: int
@onready var timer: Timer = $Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $Anim
@onready var marker: Marker2D = $Marker2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if GameState.player:
		var distance = GameState.player.global_position - global_position  
		velocity = distance.normalized() * pig_speed
	move_and_slide()
		
	


func _on_timer_timeout() -> void:
	if GameState.player:
		var bullet = BULLET.instantiate()
		get_parent().add_child(bullet)
		var distance = GameState.player.global_position - global_position
		var offset = (marker.global_position - global_position).abs()
		bullet.velocity = distance.normalized() * bullet_speed
		bullet.global_position = global_position + (distance.normalized() * offset)
	
