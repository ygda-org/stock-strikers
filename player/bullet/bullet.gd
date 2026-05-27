extends CharacterBody2D

var damage = 0
var knockback = 20

var ricochet = 0
var bleed = 0
var homing = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		var body = collision.get_collider()
		if body.is_in_group("Enemies"):
			var enemy_component = body.find_child("EnemyComponent")
			enemy_component.hurt(damage, bleed)
			enemy_component.knockback(self,knockback)
		if body.is_in_group("Player"):
			pass
		else:
			hit(collision.get_normal())
	if homing:
		var target = get_nearest_enemy()
		if target:
			target = target.global_position
			velocity += ((target - global_position).normalized() * homing * delta * 100).project(velocity.normalized()-(target - global_position).normalized())
	position += velocity * delta

func hit(norm):
	if not ricochet:
		self.queue_free()
	else:
		ricochet -= 1
		velocity = velocity.bounce(norm)

func get_nearest_enemy():
	if not GameState.enemies:
		return
	var min_dist = INF
	var min_enemy = GameState.enemies[0]
	for e in GameState.enemies:
		var distance = (e.global_position-global_position).length()
		if distance < min_dist:
			min_enemy = e
	return min_enemy
