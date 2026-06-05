extends Area2D

var target_position = Vector2.ZERO

var value = 10

func _ready():
	if value == 25:
		$AnimatedSprite2D.play("gold")
	elif value == 10:
		$AnimatedSprite2D.play("silver")
	else:
		$AnimatedSprite2D.play("copper")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = global_position.lerp(target_position, delta)
	if "coin_magnet" in GameState.player.other_effects_list:
		global_position = global_position.lerp(GameState.player.global_position, delta*GameState.player.other_effects_strengths["coin_magnet"])


func _on_body_entered(body):
	if body.is_in_group("Player"):
		PlayerStats.money += value
		SfxManager.create_audio(SFXSettings.SFX_LABEL.Coin)
		queue_free()
