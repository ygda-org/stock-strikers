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
			var enemy_component = body.find_child("EnemyComponent")
			enemy_component.hurt(damage)
			enemy_component.knockback(self,knockback)
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
		velocity = velocity.bounce(norm)
