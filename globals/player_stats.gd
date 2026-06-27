extends Node
# this script will handle all the player money, stock, loan stuff

var money = 10
var debts = []
const INTEREST_RATE = 1.07

const BASE_STATS = [100, 120, 0, 20, 0, 200, 1, 0.3, 250, 0, 0.25, 20, null] # parallel array to enum in resource
var current_stats = []

var stocks: Array[Stock] = []
var stock_to_mult : Dictionary[String, int] = {} # stock name to int
var extra_effects: Array[String]

var permanent_upgrades: Array[Upgrade] = []
#var permanent_upgrades: Array[Upgrade] = [load("uid://ba4wpivrl3ecn"), load("uid://cisowgq6cq23"), load("uid://bi55lojalcku7"), load("uid://b5i8u8rteh6ig"), load("uid://b8nl6e38tuyvj"), load("uid://dciglotjs1626"), load("uid://01jebi1rf38g"), load("uid://bc631dr4yw316")]
var permanent_upgrades_loaded: Dictionary[String, float]

signal stocks_modified
signal upgrades_modified

func _ready():
	reload_upgrades()

## currently called by player, updates player's stats before next run
func update_stats():
	current_stats = BASE_STATS.duplicate() # copy base stats into stats every time
	for stock in stocks:
		if stock.changed_stat == Stock.stats.OTHER:
			continue # add functionality here
		current_stats[stock.changed_stat] += stock.change_amount * stock_to_mult[stock.stock_name]
	


func add_stock(s : Stock, mult : int):
	stocks.append(s)
	if s.stock_name in stock_to_mult.keys():
		stock_to_mult[s.stock_name] += mult
	else:
		stock_to_mult[s.stock_name] = mult
	stocks_modified.emit()

func remove_stock(s : Stock):
	stocks.remove_at(stocks.find(s))
	stock_to_mult[s.stock_name] = 0
	stocks_modified.emit()

func add_permanent_upgrade(u: Upgrade):
	permanent_upgrades.append(u)
	reload_upgrades()
	upgrades_modified.emit()

func remove_permanent_upgrade(u: Upgrade):
	permanent_upgrades.remove_at(permanent_upgrades.find(u))
	reload_upgrades()
	upgrades_modified.emit()

func reload_upgrades():
	for upgrade in permanent_upgrades: # adding this here lol no better place :D
		permanent_upgrades_loaded[upgrade.name] = upgrade.change_amount

func interest():
	if debts:
		SfxManager.create_audio(SFXSettings.SFX_LABEL.LosingCoin)
	for debt in debts:
		var interest_rate = INTEREST_RATE
		if "interest_rate" in permanent_upgrades_loaded.keys():
			interest_rate -= permanent_upgrades_loaded["interest_rate"]
		debt.debt = snapped(debt.debt * interest_rate, .01)

func reset_stats():
	money = 10
	debts = []
	stocks = []
	permanent_upgrades = []
	GameState.cleared_floors = 0

func get_total_debt():
	var debt = 0
	for debt_resource in debts:
		debt += debt_resource.debt
	return debt
