extends Camera2D



enum ShakeDirection {
	OMNI,
	VERTICAL,
	HORIZONTAL
}
var shake_strength: float = 0.0
var shake_type: ShakeDirection = ShakeDirection.OMNI

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	pass # Replace with function body.


const MAX_SHAKE_STRENGTH: float = 25
@export_range(0, 10, 1) var shake_fade: float = 7.0

func apply_shake(weight: float, direction: ShakeDirection = ShakeDirection.OMNI):
	shake_strength = MAX_SHAKE_STRENGTH * weight
	shake_type = direction

## Vertical Camera Shake
func apply_vertical_shake(weight: float):
	shake_strength = MAX_SHAKE_STRENGTH * weight
	shake_type = ShakeDirection.VERTICAL

## Horizontal Camera Shake
func apply_horizontal_shake(weight: float):
	shake_strength = MAX_SHAKE_STRENGTH * weight
	shake_type = ShakeDirection.HORIZONTAL
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		if shake_type == ShakeDirection.OMNI:
			offset = _generateRandomOffset()
		elif shake_type == ShakeDirection.VERTICAL:
			offset = _generateVerticalOffset()
		elif shake_type == ShakeDirection.HORIZONTAL:
			offset = _generateHorizontalOffset()


func _on_character_body_2d_camera_shake(amount: float) -> void:
	apply_shake(amount)

func _generateRandomOffset() -> Vector2:
	return Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))

func _generateVerticalOffset() -> Vector2:
	return Vector2(0, randf_range(-shake_strength, shake_strength))

func _generateHorizontalOffset() -> Vector2:
	return Vector2(randf_range(-shake_strength, shake_strength), 0)

