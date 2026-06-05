extends Area2D


func _on_body_entered(body):
	if body.is_in_group("Player") and GameState.enemies.is_empty():
		GameState.cleared_floor()
