extends Area2D

@onready var raycast = $RayCast2D
@onready var anim = $AnimatedSprite2D
@onready var collider = $CollisionShape2D

var initialized:bool = false
var target
var damage
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if initialized:
		raycast.target_position = target*100
		raycast.force_raycast_update()
		var distance = (raycast.get_collision_point()-global_position).length()
		var scalar = distance/anim.sprite_frames.get_frame_texture("laser",0).get_height()
		anim.scale.y = scalar
		anim.position.y = -distance/2.0
		collider.scale.y = scalar
		anim.position.y = -distance/2.0
		for body in get_overlapping_bodies():
			if body.is_in_group("Player"):
				body.hurt(damage)

func initialize(new_target,new_damage):
	target = new_target
	damage = new_damage
	initialized = true

func die():
	queue_free()
