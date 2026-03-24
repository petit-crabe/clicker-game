extends Control

@onready var _currency_label: Label = $HUD/CurrencyLabel
@onready var _production_label: Label = $HUD/ProductionLabel

@onready var _click_button: TextureButton = $ClickZone/ClickButton

func _ready() -> void:
	GameManager.currency_changed.connect(_on_currency_changed)
	_on_currency_changed(GameManager.currency)
	_production_label.text = "⚡ 0 / s"
	_click_button.pressed.connect(_on_click_button_pressed)
	
func _on_currency_changed(new_amount: float) -> void:
	_currency_label.text = "💰 " + GameManager.format_number(new_amount)

func _on_click_button_pressed() -> void:
	_spawn_floating_number(GameManager.currency_per_click, _click_button.global_position)
	
func _spawn_floating_number(value: float, origin: Vector2) -> void:
	var label := Label.new()
	
	label.text = "+%s" % GameManager.format_number(value)
	label.position = origin + Vector2(randf_range(-40.0, 40.0), -20)
	label.add_theme_color_override("font_color", Color.YELLOW)
	label.add_theme_font_size_override("font_size", 28)
	
	add_child(label)
	
	var tween := create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 100.0, 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	
	await tween.finished
	
	label.queue_free()
	
