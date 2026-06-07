extends Node2D

class_name Room

@export var has_north : bool = false
@export var has_south : bool = false
@export var has_east : bool = false
@export var has_west : bool = false

@export var north_edge_fix: bool = false
@export var full_size: bool = false

@export var spawns: Array[Vector2] = [Vector2(128,128)]

@onready var center : Vector2 = position + Vector2(128,128)

var room_entered := false
var has_enemies := true
var my_enemies : Array = []

var tilemaps : Array[TileMapLayer] = []

func _ready() -> void:
	var coin_room = GameState.roll_coin_room()
	for poz in spawns:
		if coin_room:
			var coin = load("uid://d1hijr3si4jyw").instantiate()
			coin.position = poz
			coin.value = 25
			add_child(coin)
			continue
		var enemy: CharacterBody2D = select_enemy().instantiate()
		enemy.position = poz
		enemy.get_node("EnemyComponent").set_scalar(GameState.get_current_scalar())
		my_enemies.append(enemy)
		add_child(enemy)
	for node in get_children():
		if node is TileMapLayer:
			tilemaps.append(node)

func select_enemy():
	var cum_percent : float = 0
	var val := randf()
	for k in (GameState.enemy_rate.keys()):
		cum_percent += GameState.enemy_rate[k]
		if val < cum_percent:
			return k
	print('Warning: Total Enemy rates likely dont add to 100%' )

func _process(delta: float) -> void:
	if not has_enemies:
		return

	if room_entered:
		if has_enemies and not check_enemies():
			on_all_enemies_dead()
		return

	var sq_dist_to_player := (GameState.player.position - center).length_squared()
	# 128**2 = 16384
	if sq_dist_to_player < 16384:
		room_entered = true
		for child in get_children():
			if child is TileMapLayer:
				continue
			var e_comp : EnemyComponent = child.find_child("EnemyComponent")
			if e_comp != null:
				e_comp.enable()

func check_enemies():
	for e in my_enemies:
		if e != null:
			return true
	return false

func on_all_enemies_dead():
	has_enemies = false
	GameState.on_room_clear(global_position)

func set_floors(new_floor):
	for tilemap: TileMapLayer in tilemaps:
		pass
func set_walls(new_walls):
	pass
