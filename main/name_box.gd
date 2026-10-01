extends Panel

signal name_entered
var entered_name = ""

func _ready():
	$VBoxContainer/Label.text = Leaderboard.get_top_three_string()

func _on_confirm_button_pressed():
	entered_name = $VBoxContainer/TextEdit.text
	name_entered.emit()
	await get_tree().process_frame
	queue_free()
