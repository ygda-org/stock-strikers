extends Node2D

@onready var Anim:AnimatedSprite2D = $Anim
var flashed: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func flash(time:float):
	flashed = true
	Anim.speed_scale = (1.0/time)
	Anim.play("flash")
	await Anim.animation_finished
	queue_free()
