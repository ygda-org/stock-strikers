extends Control

var debt_resource

func _on_button_pressed():
	get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().pay_debt(self)
