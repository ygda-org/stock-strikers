extends Node2D

class_name EnemyComponent

@onready var animation = get_parent().get_node_or_null("AnimatedSprite2D")
@onready var parent = get_parent()
@onready var health_bar: ProgressBar = $HealthBar
@export var money_on_kill: int = 40
@export var kb_decel: float = 4
@export var self_collision_kb: float = 300
var is_knockback:bool = false
var is_stunned:bool = false
var is_alive:bool = true

var current_bleed = 0
var bleed_count

@export var max_health := 30
@export var contact_damage: int = 10
@onready var current_health = max_health

const COIN = preload("uid://d1hijr3si4jyw")

func _ready():
	parent.z_as_relative = false
	health_bar.max_value = max_health
	health_bar.value = current_health
	GameState.enemies.append(get_parent())
	if "money_on_kill" in PlayerStats.permanent_upgrades_loaded:
		money_on_kill *= PlayerStats.permanent_upgrades_loaded["money_on_kill"]
	if "enemy_move_speed" in PlayerStats.permanent_upgrades_loaded and "speed" in get_parent():
		get_parent().speed *= PlayerStats.permanent_upgrades_loaded["enemy_move_speed"]
	if "enemies_produce_light" in PlayerStats.permanent_upgrades_loaded:
		$PointLight2D.enabled = true
		$PointLight2D.scale *= PlayerStats.permanent_upgrades_loaded["enemies_produce_light"]
	disable()

func enable():
	parent.process_mode = Node.PROCESS_MODE_ALWAYS
	pass

func disable():
	parent.process_mode = Node.PROCESS_MODE_DISABLED
	pass

func align_enemy_marker():
	var from_p_to_self : Vector2 = global_position - GameState.player.camera.global_position
	var marker_offset : Vector2
	#if abs(from_p_to_self.x) < abs(from_p_to_self.y):
		#marker_offset.y = 50 * sign(from_p_to_self.y)
		#marker_offset.x = 50 * from_p_to_self.x/from_p_to_self.y * sign(from_p_to_self.x)
	#else:
		#marker_offset.x = 50 * sign(from_p_to_self.x)
		#marker_offset.y = 50 * from_p_to_self.y/from_p_to_self.x * sign(from_p_to_self.y)
	marker_offset = from_p_to_self.normalized() * 100
	$EnemyMarker.global_position = GameState.player.camera.global_position + marker_offset
	$EnemyMarker.rotation = marker_offset.angle()

func _process(delta):
	align_enemy_marker()
	
	parent.z_index = position.y/256
	
	if is_knockback:
		parent.velocity = lerp(parent.velocity, Vector2.ZERO, kb_decel * delta)
		if parent.velocity.length() < 10:
			parent.velocity = Vector2.ZERO
			is_knockback = false
			is_stunned = false
			if animation:
				animation.play("hop")

func process_collisions(collisions):
	var player_got_hit = false
	for i in len(collisions):
		var body = collisions[i].get_collider()
		if !body:
			continue
		if body.is_in_group("Player") and !player_got_hit:
			body.hurt(contact_damage)
			knockback(body,self_collision_kb)
			player_got_hit = true
			if "thorns" in body.other_effects_list:
				hurt(body.other_effects_strengths["thorns"], 0)

func knockback(object,speed:float):
	if !is_knockback:
		parent.velocity = (object.global_position - global_position).normalized() * speed * -1
		is_knockback = true
		is_stunned = true
		if animation:
			animation.stop()

func hurt(health, bleed = 0):
	if "piggy_bank" in parent:
		SfxManager.create_audio(SFXSettings.SFX_LABEL.PiggyBankShot)
	elif "wallet" in parent:
		SfxManager.create_audio(SFXSettings.SFX_LABEL.WalletSomething)
	current_health -= health
	health_bar.value = current_health
	if current_health <= 0:
		die()
	if bleed:
		current_bleed += bleed
		bleed_count = 4
		$BleedTimer.start()

func die():
	is_alive = false
	if parent.has_method("die"):
		parent.die()
		if parent.has_signal("death_anim_complete"):
			await parent.death_anim_complete
	var money_gain = money_on_kill
	if "perfection" in GameState.player.other_effects_list:
		money_gain *= GameState.player.other_effects_strengths["perfection"]
	if "berserk" in GameState.player.other_effects_list:
		GameState.player.berserk_kill()
	drop_coins(money_gain)
	is_stunned = true
	GameState.enemies.erase(parent)
	parent.queue_free()

func drop_coins(money_gain):
	#for i in range(int(money_gain/10)):
	#	var coin = COIN.instantiate()
	#	coin.target_position = global_position + Vector2(20, 0).rotated(randf_range(0, 2*PI))
	#	parent.get_parent().add_child(coin)
	#	coin.global_position = global_position
	while money_gain > 0:
		var coin = COIN.instantiate()
		if money_gain >= 25:
			coin.value = 25
			money_gain -= 25
		elif money_gain >= 10:
			coin.value = 10
			money_gain -= 10
		else:
			coin.value = 1
			money_gain -= 1
		coin.target_position = global_position + Vector2(20, 0).rotated(randf_range(0, 2*PI))
		parent.get_parent().add_child(coin)
		coin.global_position = global_position

func _on_bleed_timer_timeout():
	current_health -= current_bleed
	health_bar.value = current_health
	if current_health <= 0:
		die()
	bleed_count -= 1
	if bleed_count <= 0:
		current_bleed = 0
		return
	$BleedTimer.start()

func set_scalar(s):
	max_health *= s
	contact_damage *= s
	if "bullet_damage" in get_parent():
		get_parent().bullet_damage *= s/6


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	$EnemyMarker.visible = false


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	$EnemyMarker.visible = true
