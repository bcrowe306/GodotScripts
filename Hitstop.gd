extends Node
class_name Hitstop

var timer: Timer
const MAX_HITSTOP_DURATION: float = 1.0
## Freezes the game for the specified duration to create a hitstop effect.
func _ready() -> void:
	timer = Timer.new()
	timer.ignore_time_scale = true
	timer.wait_time = 0.1
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_hitstop_timeout)

func _on_hitstop_timeout() -> void:
	Engine.time_scale = 1.0


func trigger_hitstop(weight: float) -> void:
	if timer.is_stopped():
		timer.wait_time = clampf(weight * MAX_HITSTOP_DURATION, 0.0, MAX_HITSTOP_DURATION)
		timer.start()
		Engine.time_scale = 0.1
	else:
		Engine.time_scale = 1.0
