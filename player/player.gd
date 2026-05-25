extends CharacterBody2D

@export var acceleration_curve: Curve

const ACCELERATION = 3000
const DECELERATION = 120
const SPEED = 100

const BULLET = preload("uid://ckwbgunr68qm")

var invincible: bool = false

@onready var collision_shape:CollisionShape2D = $CollisionShape2D
@onready var itimer:Timer = $InvincibleTimer
func _ready(): # probably load stats from gamestate right
	GameState.player = self

func _process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir.x:
		velocity.x = velocity.x + acceleration_curve.sample(abs(velocity.x/SPEED)) * input_dir.x * ACCELERATION * delta
	else:
		velocity.x = 0
	if input_dir.y:
		velocity.y = velocity.y + acceleration_curve.sample(abs(velocity.y/SPEED)) * input_dir.y * ACCELERATION * delta
	else:
		velocity.y = 0
	velocity = velocity.limit_length(SPEED)
		#velocity = lerp(velocity, Vector2.ZERO, DECELERATION * delta)
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
		
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body.is_in_group("Player"):
			if !invincible:
				invincible = true
	move_and_slide()
	

func shoot():
	var target_position = get_global_mouse_position()
	var bullet = BULLET.instantiate()
	bullet.velocity = (target_position-global_position).normalized()*100 # idk bullet shoot speed for now
	get_parent().add_child(bullet)
	bullet.global_position = global_position
func hurt():
	set_collision_layer_value(1,false)
	itimer.start()
	

func _on_invincible_timer_timeout() -> void:
	invincible = false
	set_collision_layer_value(1,true)
