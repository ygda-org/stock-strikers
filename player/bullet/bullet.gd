extends CharacterBody2D

var speed = 100

var damage = 0
var knockback = 20

var ricochet = 0
var bleed = 0
var homing = 0
var vampire = 0
var guiding = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		var body = collision.get_collider()
		if body.is_in_group("Enemies"):
			var enemy_component = body.find_child("EnemyComponent")
			enemy_component.hurt(damage, bleed)
			enemy_component.knockback(self,knockback)
			if vampire:
				GameState.player.current_health += vampire * damage
				GameState.player.player_hp_update.emit(GameState.player.max_health, GameState.player.current_health)
		if body.is_in_group("Player"):
			pass
		else:
			hit(collision.get_normal())
	if homing:
		var target = get_nearest_enemy()
		if target:
			target = target.global_position
			velocity += ((target - global_position).normalized() * homing * delta * 100).project(velocity.normalized()-(target - global_position))#.normalized())
	if guiding:
		var target = get_global_mouse_position()
		velocity += ((target - global_position).normalized() * guiding * delta * 100).project(velocity.normalized()-(target - global_position))#.normalized())
	if velocity.length() != speed:
		velocity = velocity.normalized() * speed

func hit(norm):
	if not ricochet:
		self.call_deferred("queue_free")
	else:
		SfxManager.create_audio(SFXSettings.SFX_LABEL.BulletBounce)
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
			min_dist = distance
			min_enemy = e
	return min_enemy


func _on_timer_timeout():
	$AnimationPlayer.play("time_out")
