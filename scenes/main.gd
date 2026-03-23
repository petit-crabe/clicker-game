extends Control

@onready var _currency_label: Label = $HUD/CurrencyLabel
@onready var _production_label: Label = $HUD/ProductionLabel

func _ready() -> void:
	GameManager.currency_changed.connect(_on_currency_changed)
	
	_on_currency_changed(GameManager.currency)
	
	_production_label.text = "⚡ 0 / s"
	
func _on_currency_changed(new_amount: float) -> void:
	_currency_label.text = "💰 " + GameManager.format_number(new_amount)
