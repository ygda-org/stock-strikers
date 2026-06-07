extends CharacterBody2D

signal death_anim_complete

@onready var enemy_component = $EnemyComponent
@onready var animation:AnimatedSprite2D = $Anim
@onready var hurtbox:CollisionShape2D = $CollisionShape2D

var speed: int = 100
# Called when the node enters the scene tree for the first time.

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
var movement_delta: float

func _ready() -> void:
	animation.play("side")
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func set_movement_target(movement_target: Vector2):
	navigation_agent.set_target_position(movement_target)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	#move_and_slide()

func pathfind(delta : float):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return

	movement_delta = speed
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_delta
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if GameState.player and !enemy_component.is_stunned:
		#var distance = GameState.player.global_position - global_position  
		#velocity = distance.normalized() * speed
		set_movement_target(GameState.player.position)
		pathfind(delta)
	var collisions = [] # need these 4 lines in every enemy's physics process
	for i in get_slide_collision_count():
		collisions.append(get_slide_collision(i))
	enemy_component.process_collisions(collisions)
	move_and_slide()
	if !enemy_component.is_stunned and enemy_component.is_alive:
		choose_anim(velocity)

func die():
	hurtbox.disabled = true
	enemy_component.is_stunned = true
	animation.play("death")
	animation.flip_h = false
	await animation.animation_finished
	death_anim_complete.emit()
	return

func choose_anim(vel:Vector2):
	if vel.angle() > (3*PI)/4 or vel.angle() < -(3*PI)/4:
		if not animation.animation == "side":
			animation.play("side")
		animation.flip_h = false
		return
	if vel.angle() < (3*PI)/4 and vel.angle() < -PI/4:
		if not animation.animation == "back":
			animation.play("back")
		animation.flip_h = false
		return
	if vel.angle() < (PI)/4 and vel.angle() > -PI/4:
		if not animation.animation == "side":
			animation.play("side")
		animation.flip_h = true
		return
	if vel.angle() > PI/4 and vel.angle() < (3*PI)/4:
		if not animation.animation == "front":
			animation.play("front")
		animation.flip_h = false
		return
