extends Panel

@onready var _name_label: Label = $VBoxContainer/NameLabel
@onready var _level_label: Label = $VBoxContainer/LevelLabel
@onready var _cost_label: Label = $VBoxContainer/CostLabel
@onready var _buy_button: Button = $VBoxContainer/BuyButton

var _upgrade_id: String = ""

const DISPLAY_NAMES: Dictionary = {
	"better_click": "Improved click",
	"auto-click": "Auto-click"
}

func setup(upgrade_id: String) -> void:
	_upgrade_id = upgrade_id
	
	_buy_button.pressed.connect(_on_buy_pressed)
	
	GameManager.currency_changed.connect(_on_currency_changed)
	
	_refresh()
	
func _refresh() -> void:
	var data: Dictionary = GameManager.upgrades[_upgrade_id]
	var cost: float = GameManager._get_upgrade_cost(_upgrade_id)
	
	_name_label.text = DISPLAY_NAMES.get(_upgrade_id, _upgrade_id)
	_level_label.text = "Level %d" % data["level"]
	_cost_label.text = "Cost %s" % GameManager.format_number(cost)
	
	_buy_button.disabled = GameManager.currency < cost

func _on_buy_pressed() ->void:
	if GameManager.buy_upgrade(_upgrade_id):
		_refresh()
		
func _on_currency_changed(_amount: float) -> void:
	_refresh()
