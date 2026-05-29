extends Control

var connected : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameState.player and !connected:
		GameState.player.player_hp_update.connect(_on_player_hp_update)
		connected = true

func _on_player_hp_update(max_hp,current_hp):
	$Bar.max_value = max_hp
	$Bar.value = current_hp
