extends Node2D

class_name Room

@export var has_north : bool = false
@export var has_south : bool = false
@export var has_east : bool = false
@export var has_west : bool = false

@export var north_edge_fix: bool = false

@export var spawns: Array[Vector2] = [Vector2(128,128)]

@onready var center : Vector2 = position + Vector2(128,128)

func _ready() -> void:
	for poz in spawns:
		pass

func _process(delta: float) -> void:
	var sq_dist_to_player := (GameState.player.position - center).length_squared()
	
