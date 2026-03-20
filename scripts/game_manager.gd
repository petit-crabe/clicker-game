extends Node

signal currency_changed(new_amount: float)

var currency: float = 0.0

var currency_per_click: float = 1.0

func click() -> void:
	_add_currency(currency_per_click)
	
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
