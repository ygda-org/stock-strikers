extends CharacterBody2D

@onready var enemy_component = $EnemyComponent
@onready var animation:AnimatedSprite2D = $Anim

@export var card_speed: int
@export var bullet_damage: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("fly")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameState.player and !enemy_component.is_stunned:
		var distance = GameState.player.global_position - global_position  
		velocity = distance.normalized() * card_speed
		
	var collisions = [] # need these 4 lines in every enemy's physics process
	for i in get_slide_collision_count():
		collisions.append(get_slide_collision(i))
	enemy_component.process_collisions(collisions)
	pass
	
	move_and_slide()
