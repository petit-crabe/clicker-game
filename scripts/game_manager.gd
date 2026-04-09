extends Node

signal currency_changed(new_amount: float)
signal production_changed(new_rate: float)
signal achievement_unlocked(id: String)

var currency: float = 0.0
var currency_per_click: float = 1.0
var currency_per_second: float = 0.0

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

var generators: Dictionary = {
	"cursor": {"level": 0, "production": 0.1, "base_cost": 15.0, "cost_multiplier": 1.15},
	"grandma": {"level": 0, "production": 1.0, "base_cost": 100.0, "cost_multiplier": 1.15},
	"farm": {"level": 0, "production": 8.0, "base_cost": 1100.0, "cost_multiplier": 1.15},
	"mine": {"level": 0, "production": 47.0, "base_cost": 12000.0, "cost_multiplier": 1.15},
	"factory": {"level": 0, "production": 260.0, "base_cost": 130000.0, "cost_multiplier": 1.15}
}

var achievements: Dictionary = {
	"first_click":  { "unlocked": false, "label": "First step !"      },
	"millionaire":  { "unlocked": false, "label": "Millionaire !"     },
	"big_producer": { "unlocked": false, "label": "Big producer !"  }
}

func _ready() -> void:
	SaveSystem.load_game()

func _process(delta: float) -> void:
	if currency_per_second > 0.0:
		_add_currency(currency_per_second * delta)

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
	
	currency_changed.emit(currency)
	_recalculate_production()
	SaveSystem.save_game()
	return true
	
func get_generator_cost(id: String) -> float:
	if not generators.has(id):
		return 0.0
	
	var data: Dictionary = generators[id]
	return data["base_cost"] * pow(data["cost_multiplier"], data["level"])
	
func buy_generator(id: String) -> bool:
	var cost := get_generator_cost(id)
	if currency < cost:
		return false
		
	currency -= cost
	generators[id]["level"] += 1
	
	currency_changed.emit(currency)
	_recalculate_production()
	SaveSystem.save_game()
	return true

func _recalculate_production() -> void:
	currency_per_second = 0.0
	
	for id in generators:
		var gen: Dictionary = generators[id]
		currency_per_second += gen["production"] * gen["level"]
		
	currency_per_second += upgrades["auto_click"]["level"] * 0.1
	
	production_changed.emit(currency_per_second)

func _check_achievements() -> void:
	if not achievements["first_click"]["unlocked"] and currency >= 1.0:
		_unlock_achievement("first_click")
	if not achievements["millionaire"]["unlocked"] and currency >= 1_000_000.0:
		_unlock_achievement("millionaire")
	if not achievements["big_producer"]["unlocked"] and currency_per_second >= 100.0:
		_unlock_achievement("big_producer")

func _unlock_achievement(id: String) -> void:
	achievements[id]["unlocked"] = true
	achievement_unlocked.emit(id)
	SaveSystem.save_game()

func _add_currency(amount: float) -> void:
	currency += amount
	currency_changed.emit(currency)
	_check_achievements()
	
func format_number(value: float) -> String:
	if value < 1.0:
		return "%.2f" % value
	elif value < 1_000.0:
		return str(int(value))
	elif value < 1_000_000.0:
		return "%.1fk" % (value / 1_000.0)
	elif value < 1_000_000_000.0:
		return "%.1fM" % (value / 1_000_000.0)
	elif value < 1_000_000_000_000.0:
		return "%.1fB" % (value / 1_000_000_000.0)
	# Trillion and beyond — the idle game end-game
	return "%.1fT" % (value / 1_000_000_000_000.0)
