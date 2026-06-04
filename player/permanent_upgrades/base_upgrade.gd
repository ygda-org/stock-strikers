extends Resource

class_name Upgrade

enum modifiers {
	MONEY_ON_KILL,
	MAX_ROOM_CT, # +- val
	MIN_ROOM_CT, # +- val
	ENEMY_DENSITY,
	ENEMY_MOVE_SPEED,
	ENEMY_ATTACK_SPEED,
	ENEMIES_PRODUCE_LIGHT,
	NO_FOUR_SPLIT,
	ENEMY_DETECTION_RANGE,
	BONUS_COINS_ROOM,
	STOCK_MARKET_VOLATILITY,
	INTEREST_RATE
}

## what thing we're modifying lol
@export var modified: modifiers
## either additive or multiplicative depending on upgrade (or even a 1 or 0 bool)
@export var change_amount: float
## internal processing name
@export var name: String

@export var display_name: String
@export var attribute_text: String
@export var flavor_text: String
@export var cost: float
