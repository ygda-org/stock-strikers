extends CharacterBody2D

var damage = 0
var knockback = 20

var ricochet = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		var body = collision.get_collider()
		if body.is_in_group("Enemies"):
			body.hurt(damage)
			body.knockback(self,knockback)
		if body.is_in_group("Player"):
			pass
		else:
			hit(collision.get_normal())
	position += velocity * delta

func hit(norm):
	if not ricochet:
		self.queue_free()
	else:
		ricochet -= 1
		if norm.x:
			velocity.x *= -1
		elif norm.y:
			velocity.y *= -1
		else:
			print('aAahaadhafahfasuifhaiofw')
