extends Area2D

var velocity = Vector2(0,0)
var damage = 0
var knockback = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("Enemies"):
			body.hurt(damage)
			body.knockback(self,knockback)
		if body.is_in_group("Player"):
			continue
		hit()
	position += velocity * delta

func hit():
	self.queue_free()
	pass
