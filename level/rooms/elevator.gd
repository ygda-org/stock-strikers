extends Area2D

var open := false

func _process(delta: float) -> void:
	if not open and GameState.enemies.is_empty():
		$AudioStreamPlayer2D.playing = true
		$AnimatedSprite2D.play("open")
		open = true

func _on_body_entered(body):
	if body.is_in_group("Player") and GameState.enemies.is_empty():
		GameState.cleared_floor()
