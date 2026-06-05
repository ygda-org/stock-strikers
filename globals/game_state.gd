extends Node
var player : CharacterBody2D

var enemies = []

const CREDIT_CARD = preload("uid://diupkd5kr2tpw")
const PIGGY_BANK = preload("uid://b73ufdvihi6ks")
const WALLET = preload("uid://dmtq0eq4tnvrw")

var enemy_rate : Dictionary[Variant, float]= {
	CREDIT_CARD : 0.5,
	PIGGY_BANK : 0.1,
	WALLET : 0.4,
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

func _ready() -> void:
	var chosen_seed = randi() % 100000
	print('seed:', chosen_seed)
	seed(chosen_seed)
	get_all_stocks()
	roll_volitility()
	get_all_upgrades()

func _process(_delta):
	clear_enemies()
	if enemies.size() == 0 and in_game:
		get_tree().change_scene_to_file("res://gui/elevator_gui.tscn")
		in_game = false

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
	var dir := DirAccess.open(dir_name)
	var file_names := dir.get_files()
	for file_name in file_names:
		if 'tres' not in file_name:
			continue
		all_stocks.append(load(dir_name + file_name))

func get_all_upgrades():
	var dir_name := "res://player/permanent_upgrades/"
	var dir := DirAccess.open(dir_name)
	var file_names := dir.get_files()
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

func on_room_clear():
	print('ROOM ERADICATED')
	for s : Stock in all_stocks:
		var range : Vector2
		if stock_to_volatility[s] == "LOW":
			range = s.low_volatile_range
		elif stock_to_volatility[s] == "MED":
			range = s.med_volatile_range
		elif stock_to_volatility[s] == "HIGH":
			range = s.high_volatile_range
		var delta = randf_range(range.x,range.y)
		s.change_amount += delta
		last_stock_dir[s] = sign(delta)
		update_stock_tickers.emit()
