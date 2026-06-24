extends Node
var player : CharacterBody2D

var enemies = []

const CREDIT_CARD = preload("uid://diupkd5kr2tpw")
const PIGGY_BANK = preload("uid://b73ufdvihi6ks")
const WALLET = preload("uid://dmtq0eq4tnvrw")
const MONEY_BAG = preload("uid://cqybob226gurn")

var enemy_rate : Dictionary[Variant, float]= {
	CREDIT_CARD : 0.2,
	PIGGY_BANK : 0.2,
	WALLET : 0.4,
	MONEY_BAG : 0.4,
}

var in_game : bool = false

var stock_options : Array[Stock] = []
var upgrade_options: Array[Upgrade] # size 2

var stock_to_volatility : Dictionary[Stock, String] = {
	
}
var last_stock_dir : Dictionary[Stock, int] = {
	
}

signal update_stock_tickers

var all_stocks : Array[Stock] = []
var all_upgrades: Array[Upgrade]

var chosen_seed : int
var doors = []
var cleared_floors = 0

var music_volume : float = 1.0

func _ready() -> void:
	chosen_seed = randi() % 100000
	print('seed:', chosen_seed)
	seed(chosen_seed)
	get_all_stocks()
	roll_volitility()
	get_all_upgrades()

func _process(_delta):
	clear_enemies()
	#if enemies.size() == 0 and in_game:
	#	get_tree().change_scene_to_file("res://gui/elevator_gui.tscn")
	#	in_game = false

func cleared_floor():
	in_game = false
	cleared_floors += 1
	get_tree().change_scene_to_file("res://gui/elevator_gui.tscn")

func roll_volitility():
	for stock : Stock in all_stocks:
		var rand_num = randf()
		if rand_num < 0.5:
			stock_to_volatility[stock] = "LOW"
		elif rand_num < 0.85:
			stock_to_volatility[stock] = "MED"
		else:
			stock_to_volatility[stock] = "HIGH"

func get_all_stocks():
	var dir_name := "res://player/stocks/"
	# This "open" method returns an instance for accessing your dir
	#var dir := DirAccess.open(dir_name)
	#var file_names := dir.get_files()
	var file_names = ResourceLoader.list_directory(dir_name)
	for file_name in file_names:
		if 'tres' not in file_name:
			continue
		all_stocks.append(load(dir_name + file_name))

func get_all_upgrades():
	var dir_name := "res://player/permanent_upgrades/"
	#var dir := DirAccess.open(dir_name)
	#var file_names := dir.get_files()
	var file_names = ResourceLoader.list_directory(dir_name)
	for file_name in file_names:
		if 'tres' not in file_name:
			continue
		all_upgrades.append(load(dir_name + file_name))

func generate_stock_options():
	all_stocks.shuffle()
	stock_options = all_stocks.slice(0, 5)

func generate_upgrade_options():
	all_upgrades.shuffle()
	upgrade_options = all_upgrades.slice(0,2)

func clear_enemies():
	var indices = []
	for i in range(len(enemies)):
		if not enemies[i]:
			indices.append(i)
	var j = 0
	for i in indices:
		if i >= len(indices):
			break
		enemies.remove_at(i - j)
		j += 1

func on_room_clear(room_pos):
	print('ROOM ERADICATED')
	room_pos += Vector2(128,128)
	for door in doors:
		if not door:
			continue
		if (door.global_position - room_pos).length() < 140:
			door.open()
	for s : Stock in all_stocks:
		var range : Vector2
		if stock_to_volatility[s] == "LOW":
			range = s.low_volatile_range
		elif stock_to_volatility[s] == "MED":
			range = s.med_volatile_range
		elif stock_to_volatility[s] == "HIGH":
			range = s.high_volatile_range
		var delta = randf_range(range.x,range.y)
		delta = round(delta * 100.0)/100.0
		if "stock_market_volatility" in PlayerStats.permanent_upgrades_loaded.keys():
			delta *= PlayerStats.permanent_upgrades_loaded["stock_market_volatility"]
		s.change_amount += delta
		if s.change_amount < 0:
			s.change_amount = 0
		last_stock_dir[s] = sign(delta)
		update_stock_tickers.emit()

func get_current_scalar():
	return 1.2**(cleared_floors/3) + cleared_floors/3

func roll_coin_room():
	var chance = 10
	if "bonus_coin_rooms" in PlayerStats.permanent_upgrades_loaded.keys():
		chance -= PlayerStats.permanent_upgrades_loaded["bonus_coin_rooms"]
	return not (randi()%chance)
