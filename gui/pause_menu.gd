extends Control

@onready var audio : AudioStreamPlayer = get_parent().find_child("AudioStreamPlayer")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	GameState.music_volume = $MusicSlider.value
	if audio:
		audio.volume_linear = GameState.music_volume


func _on_button_pressed() -> void:
	get_tree().paused = false
	hide()
