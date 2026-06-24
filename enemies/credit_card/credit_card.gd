extends CharacterBody2D

@onready var enemy_component = $EnemyComponent
@onready var animation:AnimatedSprite2D = $Anim
@onready var marker:Marker2D = $Marker2D


const LASER = preload("uid://csveghgjktsk8")
var laser
var speed: int = 20
var bullet_damage: int = 16

var laser_point
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("fly")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if GameState.player and !enemy_component.is_stunned:
		var distance = GameState.player.global_position - global_position  
		velocity = distance.normalized() * speed
		shoot(GameState.player.global_position,delta)
		
		
	var collisions = [] # need these 4 lines in every enemy's physics process
	for i in get_slide_collision_count():
		collisions.append(get_slide_collision(i))
	enemy_component.process_collisions(collisions)
	pass
	
	move_and_slide()


func shoot(target,delta):
	SfxManager.create_audio(SFXSettings.SFX_LABEL.CreditCardLaser)
	if not laser:
		laser_point = Vector2.DOWN * (GameState.player.global_position - global_position)
		laser = LASER.instantiate()
		add_child(laser)
		laser.global_position = marker.global_position
		laser.initialize(laser_point,bullet_damage)
		laser.rotation = (target-global_position).angle()
	laser_point = target#lerp(laser_point,target,0.5 * delta)
	laser.target = laser_point
	laser.position = (laser_point - global_position).normalized() * (marker.global_position - global_position).length()
	laser.rotation = lerpf(laser.rotation,(laser.global_position - global_position).angle() + PI/2.0, delta)
