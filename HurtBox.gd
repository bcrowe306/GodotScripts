extends Area2D
class_name HurtBox

signal damaged(attack: Attack, hit_vector: Vector2, amount: float, new_health: float)

@export var statistics: Stats

## Takes damage from an attack, applying all attack properties.
## The attack parameter should be the Attack node that caused the damage.
func takeDamage(attack: Node, hit_vector: Vector2) -> void:
	# Verify the node is an Attack instance
	if not attack or not attack is Attack:
		return
	
	var damage_amount: float = attack.damage
	
	# Check if invincible (bypasses everything)
	if statistics.invincible:
		return
	
	# Apply damage to statistics (respects facade flag internally)
	var damaged_amount := statistics.take_damage(damage_amount)
	
	# Emit damaged signal (always emits if facade is true, otherwise only if not invincible)
	damaged.emit(attack, hit_vector, damaged_amount, statistics.health)
