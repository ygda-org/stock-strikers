extends Control

@onready var perm_panel : Panel = $PermPanel
@onready var perm_button : Button = $Background/DesktopBg/Taskbar/MarginContainer/HBoxContainer/PermButton

@onready var stock_panel : Panel = $StockPanel
@onready var stock_button : Button = $Background/DesktopBg/Taskbar/MarginContainer/HBoxContainer/StockButton

@onready var money_panel : Panel = $MoneyPanel
@onready var money_button : Button = $Background/DesktopBg/Taskbar/MarginContainer/HBoxContainer/MoneyButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
