extends Node

const SAVE_PATH := "user://save.dat"

func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("SaveSystem: could not open save file for writing.")
		return
	var data := {
		"currency": GameManager.currency,
		"currency_per_click": GameManager.currency_per_click,
		"upgrades": GameManager.upgrades,
		"generators": GameManager.generators,
	}
	
	file.store_var(data)
	file.close()
	
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
		
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("SaveSystem: could not open save file for reading.")
		return
	
	var data: Variant = file.get_var()
	file.close()
	
	if not data is Dictionary:
		push_warning("SaveSystem: save file is invalid, starting fresh.")
		return
		
	GameManager.currency = data.get("currency", 0.0)
	GameManager.currency_per_click = data.get("currency_per_click", 1.0)
	GameManager.upgrades = data.get("upgrades", GameManager.upgrades)
	GameManager.generators = data.get("generators", GameManager.generators)
	
	GameManager._recalculate_production()
	
	GameManager.currency_changed.emit(GameManager.currency)
	
func reset_game() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	get_tree().reload_current_scene()
