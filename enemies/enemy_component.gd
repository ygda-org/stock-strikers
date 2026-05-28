extends Node2D

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
	health_bar.max_value = max_health
	health_bar.value = current_health
	GameState.enemies.append(get_parent())

func _process(delta):
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
	drop_coins(money_gain)
	is_stunned = true
	GameState.enemies.erase(parent)
	parent.queue_free()

func drop_coins(money_gain):
	for i in range(int(money_gain/10)):
		var coin = COIN.instantiate()
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
