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
## amount to change stat by
@export var change_amount: float
## if other, fill in name of effect. Otherwise leave blank
@export var other_effect_name: String
