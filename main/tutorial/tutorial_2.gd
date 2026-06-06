extends Node2D


func _process(delta):
	if GameState.enemies.is_empty():
		PlayerStats.reset_stats()
		get_tree().change_scene_to_file("uid://6i6mv001enok")
