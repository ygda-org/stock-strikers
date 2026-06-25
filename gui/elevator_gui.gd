extends Control

@onready var perm_panel : Panel = $PermPanel
@onready var perm_button : Button = $Background/Taskbar/MarginContainer/HBoxContainer/PermButton

@onready var stock_panel : Panel = $StockPanel
@onready var stock_button : Button = $Background/Taskbar/MarginContainer/HBoxContainer/StockButton

@onready var money_panel : Panel = $MoneyPanel
@onready var money_button : Button = $Background/Taskbar/MarginContainer/HBoxContainer/MoneyButton

const STOCK_OPTION = preload("uid://c4m8hryyag1e6")
const DEBT_OPTION = preload("uid://dnt1y0yhe38ki")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if PlayerStats.money < 0:
		var new_debt = Loan.new()
		new_debt.title = "Outstanding Debt"
		new_debt.debt = -PlayerStats.money
		new_debt.time = "huh?"
		PlayerStats.money = 0
		PlayerStats.debts.append(new_debt)
	GameState.generate_stock_options()
	GameState.generate_upgrade_options()
	update_trendings_stocks()
	update_available_upgrades()
	update_owned_stocks()
	update_debt_options()
	PlayerStats.stocks_modified.connect(update_owned_stocks)

func _process(delta: float) -> void:
	update_balance()

func update_debt_options() -> void:
	for child in $MoneyPanel/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer.get_children():
		child.queue_free()
	for debt in PlayerStats.debts:
		var debt_option = DEBT_OPTION.instantiate()
		var debt_vbox = debt_option.get_node("Background/MarginContainer/VBoxContainer")
		debt_vbox.get_node("Label").text = debt.time
		debt_vbox.get_node("Title").text = debt.title
		debt_vbox.get_node("Amount").text = str(debt.debt)
		debt_option.debt_resource = debt
		$MoneyPanel/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer.add_child(debt_option)

func update_balance():
	$MoneyPanel/MarginContainer/VBoxContainer/HBoxContainer/Panel/MarginContainer/Balance.text = '$' + str(snappedf(PlayerStats.money,.01))

func update_owned_stocks():
	var your_stocks_holder : VBoxContainer = $"StockPanel/MarginContainer/VBoxContainer/TabContainer/Your Stocks/VBoxContainer"
	for c in your_stocks_holder.get_children():
		c.queue_free()
	for s : Stock in PlayerStats.stocks:
		var option : StockOption = STOCK_OPTION.instantiate()
		option.stock = s
		option.is_shop_stock = false
		option.volatility = GameState.stock_to_volatility[s]
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
	if upgrade1:
		vbox1.get_node("TitlePanel/Title").text = upgrade1.display_name
		vbox1.get_node("Desc").text = upgrade1.flavor_text
		vbox1.get_node("Attribute").text = upgrade1.attribute_text
		vbox1.get_node("Upgrade1Button").text = "BUY $" + str(upgrade1.cost)
	else:
		vbox1.get_node("TitlePanel/Title").text = "SOLD OUT"
		vbox1.get_node("Desc").text = "For the true monopolies"
		vbox1.get_node("Attribute").text = "You can't buy anymore upgrades"
		vbox1.get_node("Upgrade1Button").text = "NO"
		vbox1.get_node("Upgrade1Button").disabled = true
	if upgrade2:
		vbox2.get_node("TitlePanel/Title").text = upgrade2.display_name
		vbox2.get_node("Desc").text = upgrade2.flavor_text
		vbox2.get_node("Attribute").text = upgrade2.attribute_text
		vbox2.get_node("Upgrade2Button").text = "BUY $" + str(upgrade2.cost)
	else:
		vbox2.get_node("TitlePanel/Title").text = "SOLD OUT"
		vbox2.get_node("Desc").text = "For the true monopolies"
		vbox2.get_node("Attribute").text = "You can't buy anymore upgrades"
		vbox2.get_node("Upgrade2Button").text = "NO"
		vbox2.get_node("Upgrade2Button").disabled = true

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
	buy_upgrade(upgrade, $PermPanel/MarginContainer/VBoxContainer/Upgrade1/MarginContainer/VBoxContainer/Upgrade1Button)

func _on_upgrade_2_button_pressed():
	var upgrade = GameState.upgrade_options[0]
	buy_upgrade(upgrade, $PermPanel/MarginContainer/VBoxContainer/Upgrade2/MarginContainer/VBoxContainer/Upgrade2Button)


func buy_upgrade(upgrade, button) -> void:
	if button.showing_loan:
		var loan = Loan.new()
		loan.time = "blahblah"
		loan.title = upgrade.name
		loan.debt += upgrade.cost - PlayerStats.money
		PlayerStats.money = 0
		PlayerStats.debts.append(loan)
		SfxManager.create_audio(SFXSettings.SFX_LABEL.BuySuccess)
		PlayerStats.permanent_upgrades.append(upgrade)
		button.disabled = true
		update_debt_options()
		return
	if PlayerStats.money > upgrade.cost:
		SfxManager.create_audio(SFXSettings.SFX_LABEL.BuySuccess)
		PlayerStats.money -= upgrade.cost
		PlayerStats.permanent_upgrades.append(upgrade)
		button.disabled = true
	else:
		button.text = "Not enough money! Take out loan?"
		button.showing_loan = true
		SfxManager.create_audio(SFXSettings.SFX_LABEL.BuyFail) 

func pay_debt(debt_node):
	if PlayerStats.money >= debt_node.debt_resource.debt:
		PlayerStats.money -= debt_node.debt_resource.debt
		PlayerStats.debts.remove_at(PlayerStats.debts.find(debt_node.debt_resource))
		debt_node.queue_free()
		SfxManager.create_audio(SFXSettings.SFX_LABEL.BuySuccess)
	elif PlayerStats.money:
		debt_node.debt_resource.debt -= PlayerStats.money
		PlayerStats.money = 0
		SfxManager.create_audio(SFXSettings.SFX_LABEL.BuySuccess) 
	else:
		SfxManager.create_audio(SFXSettings.SFX_LABEL.BuyFail) 
	update_debt_options()
