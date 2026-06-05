extends Control

var current_text = 1

func _ready():
	PlayerStats.money = 1000

func _process(_delta):
	if Input.is_action_just_pressed("shoot"):
		if current_text < 8:
			next_text()
		else:
			var upgrade = load("uid://dciglotjs1626")
			var loan = Loan.new()
			loan.time = "blahblah"
			loan.title = upgrade.name
			loan.debt += upgrade.cost - PlayerStats.money
			PlayerStats.money = 0
			PlayerStats.debts.append(loan)
			SfxManager.create_audio(SFXSettings.SFX_LABEL.BuySuccess)
			PlayerStats.add_permanent_upgrade(upgrade)
			PlayerStats.add_stock(load("uid://b33t7ajrees8m"), 1.0)
			PlayerStats.stocks_modified.emit()
			get_tree().call_deferred("change_scene_to_file", "uid://dqak3awcpfb8w")

func next_text():
	get_node("Label" + str(current_text)).queue_free()
	current_text += 1
	get_node("Label" + str(current_text)).visible = true
	if current_text == 3:
		$ElevatorGui._on_stock_button_pressed()
	elif current_text == 5:
		$ElevatorGui._on_perm_button_pressed()
	elif current_text == 7:
		$ElevatorGui._on_money_button_pressed()
