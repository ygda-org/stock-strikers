extends Node2D

@onready var animation = get_parent().get_node_or_null("AnimatedSprite2D")
@onready var parent = get_parent()
@onready var health_bar: ProgressBar = $HealthBar
@export var kb_decel: float = 4
@export var self_collision_kb: float = 300
var is_knockback:bool = false
var is_stunned:bool = false

var current_bleed = 0
var bleed_count

@export var max_health := 30
@export var contact_damage: int = 10
@onready var current_health = max_health

func _ready():
	health_bar.max_value = max_health
	health_bar.value = current_health
	GameState.enemies.append(get_parent())

func _process(delta):
	if is_knockback:
		parent.velocity = lerp(parent.velocity, Vector2.ZERO, kb_decel * delta)
		if parent.velocity.length() < 10:
			is_knockback = false
			is_stunned = false
			if animation:
				animation.play("hop")

func process_collisions(collisions):
	var player_got_hit = false
	for i in len(collisions):
		var body = collisions[i].get_collider()
		if body.is_in_group("Player") and !player_got_hit:
			body.hurt(contact_damage)
			knockback(body,self_collision_kb)
			player_got_hit = true

func knockback(object,speed:float):
	if !is_knockback:
		parent.velocity = (object.global_position - global_position).normalized() * speed * -1
		is_knockback = true
		is_stunned = true
		if animation:
			animation.stop()

func hurt(health, bleed = 0):
	current_health -= health
	health_bar.value = current_health
	if current_health <= 0:
		die()
	if bleed:
		current_bleed += bleed
		bleed_count = 4
		$BleedTimer.start()

func die():
	is_stunned = true
	parent.queue_free()


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
