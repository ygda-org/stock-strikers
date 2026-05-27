extends Control

##If true, is on the "trending" page. Formats to be bought
##If false, is on "your stocks". Formats to be sold
@export var is_shop_stock : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not is_shop_stock:
		$VBoxContainer/BuyingRow/Dividends.visible = false
		$VBoxContainer/EffectRow/PerTag.text = 'total'
		$VBoxContainer/Desc.visible = false
		$VBoxContainer/VolatitlityRow.visible = true
		$VBoxContainer/BuyingRow/BuyButton.text = 'SELL'
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
