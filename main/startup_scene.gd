extends Node2D


func _on_animated_sprite_2d_animation_finished():
	$AnimationPlayer.play("fade_out")


func _on_animation_player_animation_finished(anim_name):
	pass#get_tree().change_scene_to_file("")
