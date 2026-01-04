extends Area2D
class_name HurtBox

signal damaged(attack: Attack, hit_vector: Vector2, amount: float, new_health: float)

var collision_shapes: Array[CollisionShape2D] = []

@export var hurtbox_name: String = "Default HurtBox"

func _ready() -> void:
	
	# Gather all collision shapes
	_gather_collision_shapes()
	
	# Enable hurtbox by default
	enable_hurtbox()

@export var statistics: Stats

## Gathers all CollisionShape2D children and stores them for quick access.
func _gather_collision_shapes() -> void:
	collision_shapes.clear()
	for child in get_children():
		if child is CollisionShape2D:
			collision_shapes.append(child)	

## Enables all child CollisionShape2D nodes, making the hurtbox active.
func enable_hurtbox() -> void:
	monitoring = true	
	for shape in collision_shapes:
		if shape:
			shape.set_deferred("disabled", false)


## Disalbe the hurtbox to prevent it from taking damage.
func disable_hurtbox() -> void:
	monitoring = false
	for shape in collision_shapes:
		if shape:
			shape.set_deferred("disabled", true)


## Takes damage from an attack, applying all attack properties.
## The attack parameter should be the Attack node that caused the damage.
func takeDamage(attack: Node, hit_vector: Vector2) -> void:
	# Verify the node is an Attack instance
	if not attack or not attack is Attack:
		print_debug("No valid attack passed into takeDamage() function")
		return
		
	if not statistics and statistics is not Stats:
		print_debug("No valid Stats object assigned to HurtBox")
	
	var damage_amount: float = attack.damage
	
	# Check if invincible (bypasses everything)
	if statistics.invincible:
		return
	
	# Apply damage to statistics (respects facade flag internally)
	var damaged_amount := statistics.take_damage(damage_amount)
	
	# Emit damaged signal (always emits if facade is true, otherwise only if not invincible)
	damaged.emit(attack, hit_vector, damaged_amount, statistics.health)
