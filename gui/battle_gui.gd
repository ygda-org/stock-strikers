extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.update_stock_tickers.connect(on_update_stock_tickers)
	on_update_stock_tickers()
	$DebugSeed.text = "DEBUG: " + str(GameState.chosen_seed)

func _process(_delta):
	$Panel/VBoxContainer/Money.text = "$" + str(snapped(PlayerStats.money,0.01))
	$Panel/VBoxContainer/Debt.text = "$" + str(PlayerStats.get_total_debt())
	$Panel/VBoxContainer/Floor.text = "Floor " + str(GameState.cleared_floors)

func on_update_stock_tickers():
	var half : int = int(PlayerStats.stocks.size()/2.0)
	$TickerTape.update_stocks(PlayerStats.stocks.slice(0, half))
	$TickerTape2.update_stocks(PlayerStats.stocks.slice(half))
