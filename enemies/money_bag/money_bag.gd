extends CharacterBody2D

@onready var enemy_component = $EnemyComponent
@onready var animation:AnimatedSprite2D = $Anim

var speed: int = 100
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("side")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameState.player and !enemy_component.is_stunned:
		var distance = GameState.player.global_position - global_position  
		velocity = distance.normalized() * speed
	
	var collisions = [] # need these 4 lines in every enemy's physics process
	for i in get_slide_collision_count():
		collisions.append(get_slide_collision(i))
	enemy_component.process_collisions(collisions)
	
	move_and_slide()
	choose_anim(velocity)


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
