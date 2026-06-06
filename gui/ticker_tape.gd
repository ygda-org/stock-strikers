extends Control

class_name TickerTape

const STOCK_TICKER = preload("uid://b2cb6ladwk52o")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is ssssthe elapsed time since the previous frame.
func update_stocks(stocks : Array[Stock]):
	for child in $Panel/MarginContainer/VBoxContainer.get_children():
		child.queue_free()
	for s : Stock in stocks:
		if s not in GameState.last_stock_dir.keys():
			continue
		var ticker : StockTicker = STOCK_TICKER.instantiate()
		ticker.set_ticker(s.company_ticker)
		if GameState.last_stock_dir[s] == 1:
			if GameState.stock_to_volatility[s] == "LOW":
				ticker.set_indicator(StockTicker.status.LOWUP)
			elif GameState.stock_to_volatility[s] == "MED":
				ticker.set_indicator(StockTicker.status.MEDUP)
			elif GameState.stock_to_volatility[s] == "HIGH":
				ticker.set_indicator(StockTicker.status.HIGHUP)
		elif GameState.last_stock_dir[s] == -1:
			if GameState.stock_to_volatility[s] == "LOW":
				ticker.set_indicator(StockTicker.status.LOWDOWN)
			elif GameState.stock_to_volatility[s] == "MED":
				ticker.set_indicator(StockTicker.status.MEDDOWN)
			elif GameState.stock_to_volatility[s] == "HIGH":
				ticker.set_indicator(StockTicker.status.HIGHDOWN)
		$Panel/MarginContainer/VBoxContainer.add_child(ticker)
