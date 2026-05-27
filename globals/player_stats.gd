extends Node
# this script will handle all the player money, stock, loan stuff

var money = 10

const BASE_STATS = [100, 100, 0, 20, 0.5, 200, 1, 0.3, 250, 0.5, 0.2, 20, null] # parallel array to enum in resource
var current_stats = []

var stocks: Array[Stock] = [load("res://player/stocks/bleed.tres")]
var extra_effects: Array[String] # do stirng for now, can change

## currently called by player, updates player's stats before next run
func update_stats(): 
	current_stats = BASE_STATS.duplicate() # copy base stats into stats every time
	for stock in stocks:
		if stock.changed_stat == Stock.stats.OTHER:
			continue # add functionality here
		current_stats[stock.changed_stat] += stock.change_amount
