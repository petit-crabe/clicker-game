extends TextureButton

@onready var _particles: CPUParticles2D = $Particles

func _ready() -> void:
	await get_tree().process_frame
	
	pivot_offset = size / 2.0
	
	_particles.position = size / 2.0
	
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	GameManager.click()
	
	_play_bounce()
	
	_particles.restart()
	
func _play_bounce() -> void:
	var tween := create_tween()
	
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.08)
	tween.tween_property(self, "scale", Vector2.ONE, 0.08)
