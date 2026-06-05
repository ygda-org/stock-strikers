extends Node2D

func _ready():
	for room in $Gameplay/Rooms.get_children():
		for node in room.get_children():
			if node is CharacterBody2D:
				node.queue_free()
	for node in $Gameplay.get_children():
		if node is CharacterBody2D:
			node.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_end_body_entered(body):
	if GameState.enemies.is_empty() and body.is_in_group("Player"):
		$Gameplay.queue_free()
		get_tree().change_scene_to_file("uid://bc5j7m306p35j")


func _on_piggy_activation_body_entered(body):
	if body.is_in_group("Player"):
		for pig in $Piggies.get_children():
			pig.process_mode = Node.PROCESS_MODE_ALWAYS
