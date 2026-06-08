extends Resource

class_name SFXSettings

enum SFX_LABEL{
	BuySuccess,
	BuyFail,
	Coin,
	BulletBounce,
	DodgeRoll,
	DodgeRollFast,
	Gun,
	PiggyBankShot,
	Ping,
	CreditCardLaser,
	CreditCardWing,
	DollarBill,
	Gunshot,
	LosingCoin,
	PiggyDeath,
	PiggyShotImpact,
	Sans,
	WalletAttack,
	WalletRustle,
	WalletSomething,
	Whoosh,
	ElevatorDing,
	MoneyBagHit
}

@export var label : SFX_LABEL
@export var stream : AudioStream
@export_range(-40,24) var volume : float = 1.0
@export_range(0.01, 4.0) var pitch : float = 1.0
@export var audio_start_offset : float = 0.0
