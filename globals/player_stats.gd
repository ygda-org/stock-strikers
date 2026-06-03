extends Node
# this script will handle all the player money, stock, loan stuff

var money = 10

const BASE_STATS = [100, 100, 0, 20, 0.5, 200, 1, 0.3, 250, 0.5, 0.2, 20, null] # parallel array to enum in resource
var current_stats = []

var stocks: Array[Stock] = []
var stock_to_mult : Dictionary[Stock, int] = {}
var extra_effects: Array[String]

var permanent_upgrades: Array[Upgrade] = []
var permanent_upgrades_loaded: Dictionary[int, float]

signal stocks_modified

## currently called by player, updates player's stats before next run
func update_stats():
	current_stats = BASE_STATS.duplicate() # copy base stats into stats every time
	for stock in stocks:
		if stock.changed_stat == Stock.stats.OTHER:
			continue # add functionality here
		current_stats[stock.changed_stat] += stock.change_amount * stock_to_mult[stock]
	for upgrade in permanent_upgrades: # adding this here lol no better place :D
		permanent_upgrades_loaded[upgrade.modified] = upgrade.change_amount


func add_stock(s : Stock, mult : int):
	stocks.append(s)
	stock_to_mult[s] = mult
	stocks_modified.emit()

func remove_stock(s : Stock):
	stocks.remove_at(stocks.find(s))
	stocks_modified.emit()

func add_permanent_upgrade(u: Upgrade):
	permanent_upgrades.append(u)

func remove_permanent_upgrade(u: Upgrade):
	permanent_upgrades.remove_at(permanent_upgrades.find(u))
