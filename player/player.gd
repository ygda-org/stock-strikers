extends CharacterBody2D

@export var acceleration_curve: Curve

signal player_hp_update(max_health,current_health)

const ACCELERATION = 3000
const DECELERATION = 120

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
var money_damage_multiplier: int 

var other_effects_list: Array[String] = []
var other_effects_strengths: Dictionary[String, float] = {}

@onready var collision_shape:CollisionShape2D = $CollisionShape2D
@onready var itimer:Timer = $InvincibleTimer

func _ready(): # probably load stats from gamestate right
	GameState.player = self
	player_hp_update.emit(max_health,current_health)
	# load stats
	PlayerStats.update_stats()
	max_health = PlayerStats.current_stats[Stock.stats.HEALTH]
	speed = PlayerStats.current_stats[Stock.stats.MOVE_SPEED]
	vision = PlayerStats.current_stats[Stock.stats.VISION]
	base_damage = PlayerStats.current_stats[Stock.stats.DAMAGE]
	$ShotCD.wait_time = PlayerStats.current_stats[Stock.stats.FIRE_RATE]
	bullet_speed = PlayerStats.current_stats[Stock.stats.BULLET_SPEED]
	bullet_size = PlayerStats.current_stats[Stock.stats.BULLET_SIZE]
	$DodgeDur.wait_time = PlayerStats.current_stats[Stock.stats.ROLL_DURATION]
	roll_speed = PlayerStats.current_stats[Stock.stats.ROLL_SPEED]
	$DodgeCD.wait_time = PlayerStats.current_stats[Stock.stats.ROLL_CD]
	money_damage_multiplier = PlayerStats.current_stats[Stock.stats.MONEY_DAMAGE_INCREASE]
	
	for stock in PlayerStats.stocks: # other effects will need to be added manually
		if stock.changed_stat == Stock.stats.OTHER and stock.other_effect_name:
			other_effects_list.append(stock.other_effect_name)
			other_effects_strengths[stock.other_effect_name] = stock.change_amount

	current_health = max_health

func _process(delta):
	damage = base_damage
	damage = process_damage_multipliers(damage)
	if Input.is_action_just_pressed("dodge") and $DodgeCD.is_stopped() and $DodgeDur.is_stopped():
		$DodgeDur.start()
		$DodgeInvincibilityDur.start()
		set_collision_layer_value(1,false)
		velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * roll_speed
	if not $DodgeDur.is_stopped():
		move_and_slide()
		return
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir.x:
		velocity.x = velocity.x + acceleration_curve.sample(abs(velocity.x/speed)) * input_dir.x * ACCELERATION * delta
	else:
		velocity.x = 0
	if input_dir.y:
		velocity.y = velocity.y + acceleration_curve.sample(abs(velocity.y/speed)) * input_dir.y * ACCELERATION * delta
	else:
		velocity.y = 0
	velocity = velocity.limit_length(speed)
		#velocity = lerp(velocity, Vector2.ZERO, DECELERATION * delta)
	
	if Input.is_action_just_pressed("shoot") and $ShotCD.is_stopped():
		shoot()
	
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body.is_in_group("Player"):
			if !invincible:
				invincible = true

func shoot():
	$ShotCD.start()
	var target_position = get_global_mouse_position()
	var bullet = BULLET.instantiate()
	bullet.velocity = (target_position-global_position).normalized()*bullet_speed
	bullet.damage = damage
	bullet.scale = Vector2(bullet_size, bullet_size)
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	if "triple_shot" in other_effects_list:
		triple_shot(target_position)

func hurt(hp_damage:int):
	if !invincible:
		if "money_shield" in other_effects_list:
			money_shield_take_damage(hp_damage)
			return
		set_collision_layer_value(1,false)
		invincible = true
		itimer.start()
		current_health -= hp_damage
		player_hp_update.emit(max_health,current_health)
	

func _on_invincible_timer_timeout() -> void:
	invincible = false
	set_collision_layer_value(1,true)


func _on_dodge_dur_timeout():
	$DodgeCD.start()


func _on_dodge_invincibility_dur_timeout():
	if not invincible:
		set_collision_layer_value(1,true)



###########################################
# past this point is special effects
###########################################

func process_damage_multipliers(dmg):
	if money_damage_multiplier != 1:
		dmg *= money_damage_multiplier * PlayerStats.money
	# space for the rest of 'em
	return dmg

func triple_shot(target_position):
	var dmg_multiplier = other_effects_strengths["triple_shot"]
	if dmg_multiplier == -1:
		assert("ASDHAIDHODHWPIOFHJWEOP")
	var bullet2 = BULLET.instantiate()
	bullet2.velocity = ((target_position-global_position).normalized()*bullet_speed).rotated(PI/4)
	bullet2.damage = damage * dmg_multiplier
	bullet2.scale = Vector2(bullet_size, bullet_size)
	get_parent().add_child(bullet2)
	bullet2.global_position = global_position
	var bullet3 = BULLET.instantiate()
	bullet3.velocity = ((target_position-global_position).normalized()*bullet_speed).rotated(-PI/4)
	bullet3.damage = damage * dmg_multiplier
	bullet3.scale = Vector2(bullet_size, bullet_size)
	get_parent().add_child(bullet3)
	bullet3.global_position = global_position

func money_shield_take_damage(dmg):
	var multiplier = other_effects_strengths["money_shield"]
	set_collision_layer_value(1,false)
	itimer.start()
	PlayerStats.money -= int(dmg * multiplier)
	if PlayerStats.money < 0:
		current_health += int(PlayerStats.money/multiplier)
		PlayerStats.money = 0
