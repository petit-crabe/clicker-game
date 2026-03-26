extends Node

signal currency_changed(new_amount: float)

var currency: float = 0.0
var currency_per_click: float = 1.0

var upgrades: Dictionary = {
	"better_click": {
		"level": 0,
		"base_cost": 10.0,
		"cost_multiplier": 1.5,
		"description": "Increases revenue per click"
	},
	"auto_click": {
		"level": 0,
		"base_cost": 50.0,
		"cost_multiplier": 1.3,
		"description": "Generates automatic clicks"
	}
}

func click() -> void:
	_add_currency(currency_per_click)
	
func _get_upgrade_cost(id: String) -> float:
	if not upgrades.has(id):
		return 0.0
	var data: Dictionary = upgrades[id]
	return data["base_cost"] * pow(data["cost_multiplier"], data["level"])
	
func buy_upgrade(id: String) -> bool:
	var cost := _get_upgrade_cost(id)
	if currency < cost:
		return false
	
	currency -= cost
	upgrades[id]["level"] += 1
	
	match  id:
		"better_click":
			currency_per_click += 1.0
		"auto_click":
			pass
	
	return true

func _add_currency(amount: float) -> void:
	currency += amount
	currency_changed.emit(currency)
	
func format_number(value: float) -> String:
	if value < 1_000.0:
		return str(int(value))
	elif value < 1_000_000.0:
		return "%.1fk" % (value / 1_000.0)
	elif value < 1_000_000_000.0:
		return "%.1fM" % (value / 1_000_000.0)
	elif value < 1_000_000_000_000.0:
		return "%.1fB" % (value / 1_000_000_000.0)
	# Trillion and beyond — the idle game end-game
	return "%.1fT" % (value / 1_000_000_000_000.0)
