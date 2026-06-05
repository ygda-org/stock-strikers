extends Control


func _on_start_pressed():
	get_tree().change_scene_to_file("uid://dqak3awcpfb8w")


func _on_credits_pressed():
	$Credits.visible = true
	$Main.visible = false
	



func _on_back_pressed():
	$Credits.visible = false
	$Main.visible = true


func _on_tutorial_pressed():
	get_tree().change_scene_to_file("uid://bjg1ol0qd3xfm")
