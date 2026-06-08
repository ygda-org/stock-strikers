extends Control

var is_replay := false

func _ready():
	$Label.text = "Highest floor: " + str(GameState.cleared_floors)

func _on_button_pressed():
	$Button.disabled = true
	$AnimationPlayer.play("fade_out")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_out":
		PlayerStats.reset_stats()
		if is_replay:
			get_tree().change_scene_to_file("uid://dqak3awcpfb8w")
		else:
			get_tree().change_scene_to_file("uid://6i6mv001enok")


func _on_button_2_pressed() -> void:
	is_replay = true
	$Button2.disabled = true
	$AnimationPlayer.play("fade_out")
