extends CanvasLayer

@onready var player = get_parent().get_node("SubViewportContainer/SubViewport/Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.update_stock_tickers.connect(on_update_stock_tickers)
	on_update_stock_tickers()
	#$DebugSeed.text = "DEBUG: " + str(GameState.chosen_seed)

func _process(_delta):
	$Panel/VBoxContainer/Money.text = "$" + str(snapped(PlayerStats.money,0.01))
	$Panel/VBoxContainer/Debt.text = "$" + str(PlayerStats.get_total_debt())
	$Panel/VBoxContainer/Floor.text = "Floor " + str(GameState.cleared_floors)
	$Panel2/VBoxContainer/DMG.text = "Dmg: " + str(player.damage)
	$Panel2/VBoxContainer/HP.text = "Max HP: " + str(player.max_health)
	$Panel2/VBoxContainer/MS.text = "MS: " + str(player.speed)
	$Panel2/VBoxContainer/ShotCD.text = "FR R8: " + str(snapped(player.get_node("ShotCD").wait_time, 0.01))

func on_update_stock_tickers():
	var half : int = int(PlayerStats.stocks.size()/2.0)
	$TickerTape.update_stocks(PlayerStats.stocks.slice(0, half))
	$TickerTape2.update_stocks(PlayerStats.stocks.slice(half))
