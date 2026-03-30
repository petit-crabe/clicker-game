extends Panel

@onready var _name_label: Label = $HBoxContainer/InfoContainer/NameLabel
@onready var _level_label: Label = $HBoxContainer/InfoContainer/LevelLabel
@onready var _production_label: Label = $HBoxContainer/InfoContainer/ProductionLabel
@onready var _buy_button: Button = $HBoxContainer/InfoContainer/BuyButton

var _generator_id: String = ""

const DISPLAY_NAMES: Dictionary = {
	"cursor": "🖱️ Cursor",
	"grandma": "👵 Grandma",
	"farm": "🌾 Farm",
	"mine": "⛏️ Mine",
	"factory": "🏭 Factory"
}

func setup(generator_id: String) -> void:
	_generator_id = generator_id
	_buy_button.pressed.connect(_on_buy_pressed)
	GameManager.currency_changed.connect(_on_currency_changed)
	_refresh()
	
func _refresh() -> void:
	var data: Dictionary = GameManager.generators[_generator_id]
	var cost: float = GameManager.get_generator_cost(_generator_id)
	var total_prod: float = data["production"] * data["level"]
	
	_name_label.text = DISPLAY_NAMES.get(_generator_id, _generator_id)
	_level_label.text = "x%d" % data["level"]
	_production_label.text = "%s/s" % GameManager.format_number(total_prod)
	_buy_button.text = GameManager.format_number(cost)
	_buy_button.disabled = GameManager.currency < cost
	
func _on_buy_pressed() -> void:
	if GameManager.buy_generator(_generator_id):
		_refresh()
	
func _on_currency_changed(_amount: float) -> void:
	_refresh()
