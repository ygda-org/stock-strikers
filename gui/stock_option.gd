extends Control

class_name StockOption

##If true, is on the "trending" page. Formats to be bought
##If false, is on "your stocks". Formats to be sold
@export var is_shop_stock : bool = true

var stock : Stock

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
	
	title = stock.company_ticker
	effect_amount = stock.change_amount
	effect_name = stock.stat_unit
	desc = stock.stock_description
	tooltip_desc = stock.effect_description
	cost_per = stock.change_amount * stock.cost_multi
	
	$Title.text = title
	$VBoxContainer/Desc.text = desc
	$VBoxContainer/EffectRow/Panel/MarginContainer/Effect.text = str(effect_amount) + " " + effect_name
	$Tooltip/MarginContainer/TooltipDesc.text = tooltip_desc
	$VBoxContainer/BuyingRow/DividendCost.text = "$" + str(cost_per) + " *"
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


func _on_buy_button_pressed() -> void:
	var dividend_ct : SpinBox = $VBoxContainer/BuyingRow/Dividends
	if is_shop_stock:
		if dividend_ct.value * cost_per > PlayerStats.money:
			print('POOR')
			return
		$Disable.visible = true
		PlayerStats.money -= dividend_ct.value * cost_per
		PlayerStats.add_stock(stock)
	else:
		pass
