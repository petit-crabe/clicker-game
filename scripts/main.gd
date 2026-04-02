extends Control

@onready var _currency_label: Label = $HUD/CurrencyLabel
@onready var _production_label: Label = $HUD/ProductionLabel
@onready var _click_button: TextureButton = $ClickZone/ClickButton

@onready var _upgrade_list: VBoxContainer = $ShopTabs/Upgrades/UpgradeList
@onready var _generator_list: VBoxContainer = $ShopTabs/Generators/GeneratorList

const UPGRADE_BUTTON_SCENE := preload("res://scenes/ui/upgrade_button.tscn")
const GENERATOR_ITEM_SCENE := preload("res://scenes/ui/generator_item.tscn")

func _ready() -> void:
	GameManager.currency_changed.connect(_on_currency_changed)
	GameManager.production_changed.connect(_on_production_changed)
	
	_on_currency_changed(GameManager.currency)
	_on_production_changed(GameManager.currency_per_second)
	
	_click_button.pressed.connect(_on_click_button_pressed)
	
	_build_upgrade_ui()
	_build_generator_ui()
	
	var save_timer := Timer.new()
	save_timer.wait_time = 30.0
	save_timer.autostart = true
	save_timer.timeout.connect(SaveSystem.save_game)
	add_child(save_timer)
	
func _build_upgrade_ui() -> void:
	for id in GameManager.upgrades:
		var btn: Control = UPGRADE_BUTTON_SCENE.instantiate()
		
		_upgrade_list.add_child(btn)
		btn.setup(id)

func _build_generator_ui() -> void:
	for id in GameManager.generators:
		var item: Control = GENERATOR_ITEM_SCENE.instantiate()
		_generator_list.add_child(item)
		item.setup(id)

func _on_currency_changed(new_amount: float) -> void:
	_currency_label.text = "💰 " + GameManager.format_number(new_amount)
	
func _on_production_changed(new_rate: float) -> void:
	_production_label.text = "⚡ %s / s" % GameManager.format_number(new_rate)

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

# === DEBUG ONLY — remove before shipping ===
func _input(event: InputEvent) -> void:
	if OS.is_debug_build():  # Safety: only works in editor/debug builds
		if event.is_action_pressed("ui_cancel"):  # Escape key — or pick another
			pass  # placeholder

			# F8 → reset save and restart
		if event is InputEventKey and event.pressed:
			if event.keycode == KEY_F8:
				print("[DEBUG] Resetting game via SaveSystem.reset_game()")
				SaveSystem.reset_game()
