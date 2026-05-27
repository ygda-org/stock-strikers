extends Area2D

var velocity:Vector2
var damage:int
var initialized = false
@onready var animation:AnimatedSprite2D = $Anim
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if initialized:
		global_position += velocity * delta 
	for body in get_overlapping_bodies():
		if body.is_in_group("Player"):
			body.hurt(damage)
		die()

func initialize(vel:Vector2):
	animation.play("shoot")
	velocity = vel
	initialized = true
func die():
	queue_free()
