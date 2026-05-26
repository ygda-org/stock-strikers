extends Area2D

var distance:Vector2
var velocity:Vector2 
@export var time:float
@export var acceleration:Vector2
@onready var timer:Timer = $Timer
var initialized:bool = false
const EXPLOSION = preload("uid://cvtvn3pfuio1q")
var damage

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if initialized:
		velocity += acceleration * delta
		position += velocity * delta
	
func initialize(new_distance:Vector2,new_position:Vector2,d:int):
	distance = new_distance
	global_position = new_position
	damage = d
	timer.wait_time = time
	velocity.y = (distance.y - 24)/time + (1/2)*(acceleration.length()*time)
	velocity.x = distance.x/time
	initialized = true
	timer.start()
	


func _on_timer_timeout() -> void:
	var explosion = EXPLOSION.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	explosion.initialize(damage)
	queue_free()
