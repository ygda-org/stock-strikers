extends Resource

class_name Stock

## stats easily changeable. Always have OTHER at the end
enum stats {
	HEALTH,
	MOVE_SPEED,
	VISION,
	DAMAGE,
	FIRE_RATE,
	BULLET_SPEED,
	BULLET_SIZE,
	ROLL_DURATION,
	ROLL_SPEED,
	ROLL_CD,
	ROLL_INVINCIBILITY_DUR,
	KNOCKBACK,
	OTHER
}
## stat to be changed. OTHER can be implemented to whatever
@export var changed_stat: stats
## For display purposes. px/s, health, $, etc
@export var stat_unit : String = "temp"
## amount to change stat by
@export var change_amount: float
## if other, fill in name of effect. Otherwise leave blank
@export var other_effect_name: String
## name of stock to be displayed in shop
@export var stock_name: String
## description of stock and effects in shop
@export var stock_description: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi"
## describes the effect, used in the tooltip
@export var effect_description : String = "Lorem Ispum"
## company ticker (EX: YGDA, APPL, etc)
@export var company_ticker : String = "AAAA"
## Cost multiplier. Price is directly proportional to change amount
@export var cost_multi : float = 2.0
