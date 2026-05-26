extends CharacterBody2D

@export var acceleration_curve: Curve

signal player_hp_update(max_health,current_health)

const ACCELERATION = 3000
const DECELERATION = 120

const BULLET = preload("uid://ckwbgunr68qm")

var invincible: bool = false
var current_health: int

var max_health: int
var speed: int
var vision: int # no implementation yet
var damage: int
var bullet_speed: int
var bullet_size: float
var roll_speed: float

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
	damage = PlayerStats.current_stats[Stock.stats.DAMAGE]
	$ShotCD.wait_time = PlayerStats.current_stats[Stock.stats.FIRE_RATE]
	bullet_speed = PlayerStats.current_stats[Stock.stats.BULLET_SPEED]
	bullet_size = PlayerStats.current_stats[Stock.stats.BULLET_SIZE]
	$DodgeDur.wait_time = PlayerStats.current_stats[Stock.stats.ROLL_DURATION]
	roll_speed = PlayerStats.current_stats[Stock.stats.ROLL_SPEED]
	$DodgeCD.wait_time = PlayerStats.current_stats[Stock.stats.ROLL_CD]


	current_health = max_health

func _process(delta):
	if Input.is_action_just_pressed("dodge") and $DodgeCD.is_stopped() and $DodgeDur.is_stopped():
		$DodgeDur.start()
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
	bullet.velocity = (target_position-global_position).normalized()*bullet_speed # idk bullet shoot speed for now
	bullet.damage = damage
	bullet.scale = Vector2(bullet_size, bullet_size)
	get_parent().add_child(bullet)
	bullet.global_position = global_position

func hurt(damage:int):
	set_collision_layer_value(1,false)
	itimer.start()
	current_health -= damage
	player_hp_update.emit(max_health,current_health)
	

func _on_invincible_timer_timeout() -> void:
	invincible = false
	set_collision_layer_value(1,true)


func _on_dodge_dur_timeout():
	$DodgeCD.start()
