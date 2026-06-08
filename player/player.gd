extends CharacterBody2D

@export var acceleration_curve: Curve

signal player_hp_update(max_health,current_health)

const ACCELERATION = 3000
const DECELERATION = 120

const RECOIL_STRENGTH = 100
const PREMIUM_BULLET_COST = 3
const MONEY_LEAK = 5

const BULLET = preload("uid://ckwbgunr68qm")

var invincible: bool = false
var roll_invincible: bool = false
var current_health: int
var damage: int = 0

var max_health: int
var speed: int
var vision: int # no implementation yet
var base_damage: int
var bullet_speed: int
var bullet_size: float
var roll_speed: float
var knockback: float

const MIN_FIRE_RATE = .2
const MIN_ROLL_CD = .3

var other_effects_list: Array[String] = []
var other_effects_strengths: Dictionary[String, float] = {}

@onready var active_arm = $ArmPivotNS

@onready var collision_shape:CollisionShape2D = $CollisionShape2D
@onready var itimer:Timer = $InvincibleTimer
@onready var camera : Camera2D = $Camera2D

func _ready(): # probably load stats from gamestate right
	GameState.player = self
	player_hp_update.emit(max_health,current_health)
	# load stats
	PlayerStats.update_stats()
	max_health = PlayerStats.current_stats[Stock.stats.HEALTH]
	speed = PlayerStats.current_stats[Stock.stats.MOVE_SPEED]
	vision = PlayerStats.current_stats[Stock.stats.VISION]
	base_damage = PlayerStats.current_stats[Stock.stats.DAMAGE]
	$ShotCD.wait_time = MIN_FIRE_RATE + 0.3/(2.7**PlayerStats.current_stats[Stock.stats.FIRE_RATE])
	bullet_speed = PlayerStats.current_stats[Stock.stats.BULLET_SPEED]
	bullet_size = PlayerStats.current_stats[Stock.stats.BULLET_SIZE]
	$DodgeDur.wait_time = PlayerStats.current_stats[Stock.stats.ROLL_DURATION]
	roll_speed = PlayerStats.current_stats[Stock.stats.ROLL_SPEED]
	$DodgeCD.wait_time = MIN_ROLL_CD + 0.4/(2.7**PlayerStats.current_stats[Stock.stats.ROLL_CD])
	knockback = PlayerStats.current_stats[Stock.stats.KNOCKBACK]
	
	for stock in PlayerStats.stocks: # other effects will need to be added manually
		if stock.changed_stat == Stock.stats.OTHER and stock.other_effect_name:
			other_effects_list.append(stock.other_effect_name)
			other_effects_strengths[stock.other_effect_name] = stock.change_amount
			
			if stock.other_effect_name == "extrafire":
				$ExtraEffects/ExtraFireCD.wait_time = stock.change_amount
				$ExtraEffects/ExtraFireCD.start()
			if stock.other_effect_name == "money_leak":
				speed *= other_effects_strengths["money_leak"]
				$ExtraEffects/MoneyLeakCD.start()
			if stock.other_effect_name == "strong_single_shots":
				base_damage *= stock.change_amount
				$ShotCD.wait_time = $ShotCD.wait_time / 2

	current_health = max_health

func _process(delta):
	z_index = position.y/256
	damage = base_damage
	damage = process_damage_multipliers(damage)
	var mouse_pos_diff = get_global_mouse_position() - global_position
	$Camera2D.position = Vector2(mouse_pos_diff.x/5, mouse_pos_diff.y/5)
	if Input.is_action_just_pressed("dodge") and $DodgeCD.is_stopped() and $DodgeDur.is_stopped():
		dodge()
	if (not $DodgeDur.is_stopped()) or (not $ExtraEffects/RecoilTimer.is_stopped()) or $AnimationPlayer.is_playing():
		move_and_slide()
		return
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir.x:
		active_arm = $ArmPivotEW
		velocity.x = velocity.x + acceleration_curve.sample(abs(velocity.x/speed)) * input_dir.x * ACCELERATION * delta
		if input_dir.x > 0:
			if not input_dir.y:
				$Anim.play("Right")
			active_arm.scale = Vector2(1, -1)
			active_arm.z_index = -1
		else:
			if not input_dir.y:
				$Anim.play("Left")
			active_arm.scale = Vector2(1, 1)
			active_arm.z_index = 0
	else:
		velocity.x = 0
	if input_dir.y:
		active_arm = $NSCenter/ArmPivotNS
		if input_dir.y > 0:
			$Anim.play("Forward")
			$NSCenter.scale = Vector2(1, 1)
		else:
			$NSCenter.scale = Vector2(-1, 1)
			$Anim.play("Backward")
		velocity.y = velocity.y + acceleration_curve.sample(abs(velocity.y/speed)) * input_dir.y * ACCELERATION * delta
	if not input_dir:
		active_arm = $NSCenter/ArmPivotNS
		$NSCenter.scale = Vector2(1,1)
		$Anim.play("idle")
		velocity.y = 0
	velocity = velocity.limit_length(speed)
		#velocity = lerp(velocity, Vector2.ZERO, DECELERATION * delta)
	active_arm.visible = true
	if "EW" in active_arm.name:
		$NSCenter/ArmPivotNS.visible = false
	else:
		$ArmPivotEW.visible = false
	
	if Input.is_action_just_pressed("shoot") and $ShotCD.is_stopped():
		shoot()
	active_arm.rotation = 0
	active_arm.look_at(get_global_mouse_position())
	if "NS" in active_arm.name:
		active_arm.rotation += PI
		if active_arm.rotation > PI/2 and active_arm.rotation < 3*PI/2:
			active_arm.get_node("Arm").flip_v = true
		else:
			active_arm.get_node("Arm").flip_v = false
	elif "EW" in active_arm.name:
		active_arm.rotation -= PI/2 * $ArmPivotEW.scale.y
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body.is_in_group("Player"):
			if !invincible:
				invincible = true

func shoot():
	SfxManager.create_audio(SFXSettings.SFX_LABEL.Gunshot)
	$ShotCD.start()
	var target_position = get_global_mouse_position()
	var bullet = create_bullet_to_spawn(damage)
	get_parent().add_child(bullet)
	bullet.global_position = active_arm.get_node("Arm/Gun").global_position
	if "triple_shot" in other_effects_list:
		triple_shot(target_position)
	if "recoil" in other_effects_list:
		recoil()
	if "extra_random_shots" in other_effects_list:
		extra_random_shot()
	if "octo_shot" in other_effects_list:
		octo_shot()

func add_bullet(bullet):
	get_parent().add_child(bullet)

func hurt(hp_damage:int):
	if !invincible:
		if "money_shield" in other_effects_list:
			money_shield_take_damage(hp_damage)
			return
		if "perfection" in other_effects_list:
			perfection_hit()
		squash_stretch(Vector2(1,0), .7)
		set_collision_layer_value(1,false)
		invincible = true
		itimer.start()
		current_health -= hp_damage
		player_hp_update.emit(max_health,current_health)
	if current_health <= 0:
		die()
	
func dodge():
	SfxManager.create_audio(SFXSettings.SFX_LABEL.DodgeRoll)
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * roll_speed
	squash_stretch(velocity.normalized(), -0.3)
	if not velocity:
		return
	$DodgeDur.start()
	$DodgeInvincibilityDur.start()
	set_collision_layer_value(1,false)
	if "roll_bullets" in other_effects_list:
		roll_bullets()
	if "teleport" in other_effects_list:
		teleport()

func _on_invincible_timer_timeout() -> void:
	invincible = false
	set_collision_layer_value(1,true)


func _on_dodge_dur_timeout():
	$DodgeCD.start()


func _on_dodge_invincibility_dur_timeout():
	if not invincible:
		set_collision_layer_value(1,true)

func squash_stretch(dir: Vector2, strength):
	var tween = get_tree().create_tween()
	tween.tween_property($Anim, "scale", Vector2(1,1)-strength*dir.sign()*dir, 0.15)
	tween.tween_property($Anim, "scale", Vector2(1,1), 0.1)

## creates a bullet and sets its initial values. Does not add child.
func create_bullet_to_spawn(dmg):
	#SfxManager.create_audio(SFXSettings.SFX_LABEL.Gun)
	var bullet = BULLET.instantiate()
	bullet.velocity = (get_global_mouse_position()-global_position).normalized()*bullet_speed
	bullet.speed = bullet_speed
	bullet.damage = dmg
	bullet.scale = Vector2(bullet_size, bullet_size)
	bullet.knockback = knockback
	if "ricochet" in other_effects_list:
		bullet.ricochet = other_effects_strengths["ricochet"]
	if "premium_bullets" in other_effects_list:
		PlayerStats.money -= PREMIUM_BULLET_COST
	if "bleed" in other_effects_list:
		bullet.bleed = other_effects_strengths["bleed"]
	if "homing" in other_effects_list:
		bullet.homing = other_effects_strengths["homing"]
	if "vampire" in other_effects_list:
		bullet.vampire = other_effects_strengths["vampire"]
	if "guided_shots" in other_effects_list:
		bullet.guiding = other_effects_strengths["guided_shots"]
	return bullet

func die():
	velocity = Vector2(0,0)
	for i in range(8):
		var coin = load("uid://d1hijr3si4jyw").instantiate()
		coin.value = 25
		coin.target_position = global_position + Vector2(30,0).rotated(i*2*PI/8)
		coin.monitoring = false
		get_parent().add_child(coin)
		coin.global_position = global_position
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("die")


func _on_animation_player_animation_finished(anim_name):
	PlayerStats.reset_stats()
	get_tree().change_scene_to_file("uid://6i6mv001enok")

###########################################
# past this point is special effects
###########################################

func process_damage_multipliers(dmg):
	var additive_dmg_mult = 1
	if "money_damage_increase" in other_effects_list:
		additive_dmg_mult += other_effects_strengths["money_damage_increase"] * PlayerStats.money
	if "premium_bullets" in other_effects_list:
		additive_dmg_mult += other_effects_strengths["premium_bullets"]
	if "desperation" in other_effects_list: # not additive cuz hech yeah YGDA
		dmg *= abs(other_effects_strengths["desperation"] * ((max_health-current_health)/max_health))
	# space for the rest of 'em
	dmg *= additive_dmg_mult
	return dmg

func triple_shot(target_position):
	var dmg_multiplier = other_effects_strengths["triple_shot"]
	var bullet2 = create_bullet_to_spawn(dmg_multiplier * damage)
	bullet2.velocity = ((target_position-global_position).normalized()*bullet_speed).rotated(PI/4)
	get_parent().add_child(bullet2)
	bullet2.global_position = global_position
	var bullet3 = create_bullet_to_spawn(dmg_multiplier * damage)
	bullet3.velocity = ((target_position-global_position).normalized()*bullet_speed).rotated(-PI/4)
	get_parent().add_child(bullet3)
	bullet3.global_position = global_position

func money_shield_take_damage(dmg):
	SfxManager.create_audio(SFXSettings.SFX_LABEL.LosingCoin)
	var multiplier = other_effects_strengths["money_shield"]
	set_collision_layer_value(1,false)
	itimer.start()
	PlayerStats.money -= int(dmg * multiplier)
	if PlayerStats.money < 0:
		current_health += int(PlayerStats.money/multiplier)
		PlayerStats.money = 0

func recoil():
	$ExtraEffects/RecoilTimer.start()
	velocity -= (get_global_mouse_position() - global_position).normalized()*other_effects_strengths["recoil"]

func roll_bullets():
	var bullet = create_bullet_to_spawn(damage*other_effects_strengths["roll_bullets"])
	bullet.velocity = -velocity/2
	get_parent().add_child(bullet)
	bullet.global_position = active_arm.get_node("Arm/Gun").global_position

func teleport():
	var target_tp_pos = velocity.normalized() * other_effects_strengths["teleport"]
	var raycast = $ExtraEffects/TeleportCheck
	raycast.target_position = target_tp_pos
	raycast.force_raycast_update()
	if raycast.is_colliding():
		position = raycast.get_collision_point()
	else:
		position += target_tp_pos


func _on_extra_fire_cd_timeout():
	shoot()

func _on_money_leak_cd_timeout():
	SfxManager.create_audio(SFXSettings.SFX_LABEL.LosingCoin)
	PlayerStats.money -= MONEY_LEAK

func perfection_hit():
	SfxManager.create_audio(SFXSettings.SFX_LABEL.LosingCoin)
	PlayerStats.money = int(PlayerStats.money * 0.9)

func extra_random_shot():
	var rando_bullet = create_bullet_to_spawn(damage * other_effects_strengths["extra_random_shots"])
	get_parent().add_child(rando_bullet)
	rando_bullet.global_position = active_arm.get_node("Arm/Gun").global_position
	rando_bullet.velocity = rando_bullet.velocity.rotated(randf_range(0,2*PI))

func octo_shot():
	for i in range(7):
		var bullet = create_bullet_to_spawn(damage * other_effects_strengths["octo_shot"])
		get_parent().add_child(bullet)
		bullet.global_position = active_arm.get_node("Arm/Gun").global_position
		bullet.velocity = bullet.velocity.rotated(i*PI/4 + PI/4)

func berserk_kill():
	base_damage *= other_effects_strengths["berserk"]
