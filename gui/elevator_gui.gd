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
	GameState.generate_upgrade_options()
	update_trendings_stocks()
	update_available_upgrades()
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

func update_available_upgrades():
	var vbox1 = $PermPanel/MarginContainer/VBoxContainer/Upgrade1/MarginContainer/VBoxContainer
	var vbox2 = $PermPanel/MarginContainer/VBoxContainer/Upgrade2/MarginContainer/VBoxContainer
	var upgrade1 = GameState.upgrade_options[0]
	var upgrade2 = GameState.upgrade_options[1]
	vbox1.get_node("TitlePanel/Title").text = upgrade1.display_name
	vbox1.get_node("Desc").text = upgrade1.flavor_text
	vbox1.get_node("Attribute").text = upgrade1.attribute_text
	vbox1.get_node("Upgrade1Button").text = "BUY $" + str(upgrade1.cost)
	vbox2.get_node("TitlePanel/Title").text = upgrade2.display_name
	vbox2.get_node("Desc").text = upgrade2.flavor_text
	vbox2.get_node("Attribute").text = upgrade2.attribute_text
	vbox2.get_node("Upgrade2Button").text = "BUY $" + str(upgrade2.cost)

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


func _on_upgrade_1_button_pressed():
	var upgrade = GameState.upgrade_options[0]
	if buy_upgrade(upgrade):
		$PermPanel/MarginContainer/VBoxContainer/Upgrade1/MarginContainer/VBoxContainer/Upgrade1Button.disabled = true

func _on_upgrade_2_button_pressed():
	var upgrade = GameState.upgrade_options[0]
	if buy_upgrade(upgrade):
		$PermPanel/MarginContainer/VBoxContainer/Upgrade2/MarginContainer/VBoxContainer/Upgrade2Button.disabled = true


func buy_upgrade(upgrade) -> bool: # returns true if successfully buys
	if PlayerStats.money > upgrade.cost: # later, do loan
		SfxManager.create_audio(SFXSettings.SFX_LABEL.BuySuccess)
		PlayerStats.money -= upgrade.cost
		PlayerStats.permanent_upgrades.append(upgrade)
		return true
	else:
		SfxManager.create_audio(SFXSettings.SFX_LABEL.BuyFail) 
		return false
