extends Area2D

var distance:Vector2
var target:Vector2
var velocity:Vector2
var shadow_velocity:Vector2 
@export var time:float
@export var acceleration:Vector2
@onready var timer:Timer = $Timer
const SHADOW = preload("uid://cieei6rv0memb")
const EXPLOSION = preload("uid://cvtvn3pfuio1q")
const MARK = preload("uid://bv5nn35mxxf8r")
var shadow
var initialized:bool = false
var shot:bool = false

var damage
var g_delta:float

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shot:
		global_position += velocity * delta
		velocity += acceleration * delta
		shadow.global_position += shadow_velocity * delta
	if initialized and !shot:
		shoot(delta)
	
func initialize(new_distance:Vector2,new_position:Vector2,d:int):
	shadow = SHADOW.instantiate()
	get_parent().add_child(shadow)
	shadow.global_position = new_position
	distance = new_distance
	global_position = new_position
	damage = d
	timer.wait_time = time
	initialized = true
func shoot(delta:float):
	var mark = MARK.instantiate()
	get_parent().add_child(mark)
	mark.global_position = target
	mark.flash(time)
	var steps = time/delta
	velocity.y = (distance.y)/time - 0.5*acceleration.y*delta*(steps-1)
	velocity.x = distance.x/time
	shadow_velocity = distance/time
	timer.start()
	shot = true 

func die():
	SfxManager.create_audio(SFXSettings.SFX_LABEL.PiggyBankShot)
	global_position = target
	var explosion = EXPLOSION.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	explosion.initialize(damage)
	shadow.queue_free()
	queue_free()
func _on_timer_timeout() -> void:
	die()
