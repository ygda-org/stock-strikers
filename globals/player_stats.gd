extends Node
# this script will handle all the player money, stock, loan stuff

var money = 10
var debts = []
const INTEREST_RATE = 1.08

const BASE_STATS = [100, 100, 0, 20, 0, 200, 1, 0.3, 250, 0, 0.2, 20, null] # parallel array to enum in resource
var current_stats = []

var stocks: Array[Stock] = []
var stock_to_mult : Dictionary[Stock, int] = {}
var extra_effects: Array[String]

var permanent_upgrades: Array[Upgrade] = [load("uid://crghvea6e7g7h")]
var permanent_upgrades_loaded: Dictionary[String, float]

signal stocks_modified

func _ready():
	reload_upgrades()

## currently called by player, updates player's stats before next run
func update_stats():
	current_stats = BASE_STATS.duplicate() # copy base stats into stats every time
	for stock in stocks:
		if stock.changed_stat == Stock.stats.OTHER:
			continue # add functionality here
		current_stats[stock.changed_stat] += stock.change_amount * stock_to_mult[stock]
	


func add_stock(s : Stock, mult : int):
	stocks.append(s)
	stock_to_mult[s] = mult
	stocks_modified.emit()

func remove_stock(s : Stock):
	stocks.remove_at(stocks.find(s))
	stocks_modified.emit()

func add_permanent_upgrade(u: Upgrade):
	permanent_upgrades.append(u)
	reload_upgrades()

func remove_permanent_upgrade(u: Upgrade):
	permanent_upgrades.remove_at(permanent_upgrades.find(u))
	reload_upgrades()

func reload_upgrades():
	for upgrade in permanent_upgrades: # adding this here lol no better place :D
		permanent_upgrades_loaded[upgrade.name] = upgrade.change_amount

func interest():
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

func get_total_debt():
	var debt = 0
	for debt_resource in debts:
		debt += debt_resource.debt
	return debt
