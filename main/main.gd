extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.in_game = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$AudioStreamPlayer.volume_linear = GameState.music_volume
	if GameState.enemies.is_empty():
		$AudioStreamPlayer.bus = &"Low"
	if Input.is_action_just_pressed("pause_game"):
		get_tree().paused = true
		$PauseMenu.visible = true
