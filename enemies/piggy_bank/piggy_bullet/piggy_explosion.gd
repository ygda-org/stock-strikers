extends Area2D

@onready var Anim:AnimatedSprite2D = $Anim
var damage:int
var initialized:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if initialized:
		for body in get_overlapping_bodies():
			if body.is_in_group("Player"):
				body.hurt(damage)
				return

func explode():
	Anim.play("explode")
	await Anim.animation_finished
	queue_free()
func initialize(d:int):
	damage = d
	explode()
	initialized = true
