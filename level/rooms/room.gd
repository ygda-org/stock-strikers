extends Node2D

class_name Room

@export var has_north : bool = false
@export var has_south : bool = false
@export var has_east : bool = false
@export var has_west : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var map : TileMapLayer = get_child(0)
	assert(map.get_used_rect().size <= Vector2i(16,16), 'ERR: Room too big')
