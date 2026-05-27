extends Control

class_name StockOption

##If true, is on the "trending" page. Formats to be bought
##If false, is on "your stocks". Formats to be sold
@export var is_shop_stock : bool = true

var title : String = "Unnamed"
var desc : String = "Blank"
var effect_amount : float = 1.0
var effect_name : String = "BOO"

### Trending Stocks
## Cost per dividend
var cost_per : float = 0.01
var tooltip_desc : String = "COOL DESC OSDKPOSDK"

### Owned Stocks
enum rate {
	STABLE,
	LOWFALL,
	LOWRISE,
	MEDFALL,
	MEDRISE,
	HIGHFALL,
	HIGHRISE,
	CHAOTIC
}
var volatility : rate = rate.STABLE
var value_total : float = 0.01

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$Title.text = title
	$VBoxContainer/Desc.text = desc
	$VBoxContainer/EffectRow/Panel/MarginContainer/Effect.text = str(effect_amount) + " " + effect_name
	$Tooltip/MarginContainer/TooltipDesc.text = tooltip_desc
	if not is_shop_stock:
		$VBoxContainer/BuyingRow/Dividends.visible = false
		$VBoxContainer/EffectRow/PerTag.text = 'total'
		$VBoxContainer/Desc.visible = false
		$VBoxContainer/VolatitlityRow.visible = true
		$VBoxContainer/BuyingRow/BuyButton.text = 'SELL'
		$VBoxContainer/VolatitlityRow/VolatilityAmount.text = str(volatility)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_info_button_toggled(toggled_on: bool) -> void:
	$Tooltip.visible = toggled_on
