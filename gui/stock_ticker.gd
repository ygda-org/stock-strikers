extends Control

class_name StockTicker

const HIGH_UP = preload("uid://c17ae83fg82wk")
const MED_UP = preload("uid://b0jy2vldsc5q6")
const LOW_UP = preload("uid://drrp437evs770")
const HIGH_DOWN = preload("uid://chktl06pm05rd")
const MED_DOWN = preload("uid://hupwxt0vp0qq")
const LOW_DOWN = preload("uid://cutbgmbp1m81t")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_ticker(ticker : String):
	$Background/Ticker.text = ticker.to_upper()

enum status{
	HIGHUP,
	MEDUP,
	LOWUP,
	LOWDOWN,
	MEDDOWN,
	HIGHDOWN,
	BLANK,
}

func set_indicator(indicator : status):
	if indicator == status.HIGHUP:
		$Background/Indicator.texture = HIGH_UP
	elif indicator == status.MEDUP:
		$Background/Indicator.texture = MED_UP
	elif indicator == status.LOWUP:
		$Background/Indicator.texture = LOW_UP
	elif indicator == status.LOWDOWN:
		$Background/Indicator.texture = HIGH_DOWN
	elif indicator == status.MEDDOWN:
		$Background/Indicator.texture = MED_DOWN
	elif indicator == status.HIGHDOWN:
		$Background/Indicator.texture = LOW_DOWN
	else:
		$Background/Indicator.texture = null
