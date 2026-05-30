extends Control

@onready var perm_panel : Panel = $PermPanel
@onready var perm_button : Button = $Background/DesktopBg/Taskbar/MarginContainer/HBoxContainer/PermButton

@onready var stock_panel : Panel = $StockPanel
@onready var stock_button : Button = $Background/DesktopBg/Taskbar/MarginContainer/HBoxContainer/StockButton

@onready var money_panel : Panel = $MoneyPanel
@onready var money_button : Button = $Background/DesktopBg/Taskbar/MarginContainer/HBoxContainer/MoneyButton

const STOCK_OPTION = preload("uid://c4m8hryyag1e6")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.generate_stock_options()
	update_trendings_stocks()
	update_owned_stocks()
	PlayerStats.stocks_modified.connect(update_owned_stocks)
	pass # Replace with function body.

func _process(delta: float) -> void:
	update_balance()

func update_balance():
	$MoneyPanel/MarginContainer/VBoxContainer/HBoxContainer/Panel/MarginContainer/Balance.text = '$' + str(PlayerStats.money)

func update_owned_stocks():
	var your_stocks_holder : VBoxContainer = $"StockPanel/MarginContainer/VBoxContainer/TabContainer/Your Stocks/VBoxContainer"
	for c in your_stocks_holder.get_children():
		c.queue_free()
	for s : Stock in PlayerStats.stocks:
		var option : StockOption = STOCK_OPTION.instantiate()
		option.stock = s
		option.is_shop_stock = false
		your_stocks_holder.add_child(option)
		option.cost_per *= PlayerStats.stock_to_mult[s]
		option.update_value()

func update_trendings_stocks():
	var your_stocks_holder : VBoxContainer = $"StockPanel/MarginContainer/VBoxContainer/TabContainer/Trending Stocks/VBoxContainer"
	for c in your_stocks_holder.get_children():
		c.queue_free()
	for s : Stock in GameState.stock_options:
		var option : StockOption = STOCK_OPTION.instantiate()
		option.stock = s
		option.is_shop_stock = true
		your_stocks_holder.add_child(option)

func _on_perm_button_pressed() -> void:
	move_child(perm_panel,-1)
	stock_button.button_pressed = false
	money_button.button_pressed = false


func _on_stock_button_pressed() -> void:
	move_child(stock_panel,-1)
	perm_button.button_pressed = false
	money_button.button_pressed = false

func _on_money_button_pressed() -> void:
	move_child(money_panel,-1)
	stock_button.button_pressed = false
	perm_button.button_pressed = false


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main/main.tscn")
