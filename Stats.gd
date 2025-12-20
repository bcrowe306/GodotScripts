extends Node
class_name Stats

## Emitted when health changes. Passes the difference and new health value.
signal health_changed(difference: float, new_value: float)

## Emitted when max_health changes. Passes the difference and new max_health value.
signal max_health_changed(difference: float, new_value: float)

## Emitted when speed changes. Passes the difference and new speed value.
signal speed_changed(difference: float, new_value: float)

## Emitted when jump_height changes. Passes the difference and new jump_height value.
signal jump_height_changed(difference: float, new_value: float)

## Emitted when powerup state changes. Passes 1 or -1 for difference and the new boolean value.
signal powerup_changed(difference: int, new_value: bool)

## Emitted when stamina changes. Passes the difference and new stamina value.
signal stamina_changed(difference: float, new_value: float)

## Emitted when armor changes. Passes the difference and new armor value.
signal armor_changed(difference: float, new_value: float)

## Emitted when armor system is enabled/disabled. Passes 1 or -1 for difference and the new boolean value.
signal armor_enabled_changed(difference: int, new_value: bool)

## Emitted when health reaches zero.
signal died



## The maximum health value. When changed, current health is clamped to not exceed this value.
@export var max_health: float = 100.0:
	set(value):
		if max_health != value:
			var old_value = max_health
			max_health = value
			var difference = max_health - old_value
			max_health_changed.emit(difference, max_health)
			# Adjust current health if it exceeds new max
			if health > max_health:
				health = max_health

## The current health value. Automatically clamped between 0 and max_health. Emits died signal when reaching zero.
@export var health: float = 100.0:
	set(value):
		var clamped_value = clamp(value, 0, max_health)
		if health != clamped_value:
			var old_value = health
			health = clamped_value
			var difference = health - old_value
			health_changed.emit(difference, health)
			if health <= 0:
				died.emit()

## The movement speed value. Used for character movement calculations.
@export var speed: float = 200.0:
	set(value):
		if speed != value:
			var old_value = speed
			speed = value
			var difference = speed - old_value
			speed_changed.emit(difference, speed)

## The jump height value. Used for character jump calculations.
@export var jump_height: float = 400.0:
	set(value):
		if jump_height != value:
			var old_value = jump_height
			jump_height = value
			var difference = jump_height - old_value
			jump_height_changed.emit(difference, jump_height)

## Boolean flag indicating whether a powerup is active.
@export var powerup: bool = false:
	set(value):
		if powerup != value:
			var old_value = powerup
			powerup = value
			var difference = 1 if (powerup and not old_value) else -1
			powerup_changed.emit(difference, powerup)

## The stamina value. Automatically clamped between 0 and 100. Used for actions like sprinting or special abilities.
@export var stamina: float = 100.0:
	set(value):
		var clamped_value = clamp(value, 0, 100.0)
		if stamina != clamped_value:
			var old_value = stamina
			stamina = clamped_value
			var difference = stamina - old_value
			stamina_changed.emit(difference, stamina)

## The armor value. Automatically clamped between 0 and 100. Higher values provide more damage reduction.
## At 100 armor, damage is completely negated. At 0 armor, full damage is taken.
@export var armor: float = 0.0:
	set(value):
		var clamped_value = clamp(value, 0, 100.0)
		if armor != clamped_value:
			var old_value = armor
			armor = clamped_value
			var difference = armor - old_value
			armor_changed.emit(difference, armor)

## Enable or disable the armor system. When disabled, damage bypasses armor calculations entirely.
@export var armor_enabled: bool = true:
	set(value):
		if armor_enabled != value:
			var old_value = armor_enabled
			armor_enabled = value
			var difference = 1 if (armor_enabled and not old_value) else -1
			armor_enabled_changed.emit(difference, armor_enabled)

## Controls how much armor degrades when damage is taken.
## Value of 0.0 means armor never degrades. Value of 1.0 means armor degrades by the full damage amount.
## Default value of 0.1 means armor degrades by 10% of the incoming damage.
@export var armor_resiliency: float = 0.1

## If true, all damage is ignored (complete invincibility).
@export var invincible: bool = false

## If true, damage calculations occur but health is not actually reduced (fake hits for visual/audio feedback).
@export var facade: bool = false

## Applies damage to health, accounting for armor if enabled.
## When armor is enabled, damage is reduced based on armor value (0-100% reduction).
## Armor also degrades based on armor_resiliency setting.
## Returns the new health value after damage is applied.
func take_damage(damage: float) -> float:
	# If invincible, ignore all damage
	if invincible:
		return health
	
	var actual_damage = damage
	
	# Apply armor reduction only if armor system is enabled
	if armor_enabled:
		# Calculate damage reduction based on armor (0-100% reduction)
		var damage_reduction = armor / 100.0
		actual_damage = damage * (1.0 - damage_reduction)
		
		# Degrade armor based on resiliency (how much armor is lost per damage taken)
		var armor_degradation = damage * armor_resiliency
		armor -= armor_degradation
	
	# Apply damage to health only if not in facade mode
	if not facade:
		health -= actual_damage
	
	return health

## Increases health by the specified amount. Health is automatically clamped to max_health.
func heal(amount: float) -> void:
	health += amount

## Sets a new maximum health value and adjusts current health if it exceeds the new maximum.
## Note: This directly emits max_health_changed signal without going through the setter.
func set_max_health(new_max: float) -> void:
	max_health = new_max
	health = min(health, max_health)
	max_health_changed.emit(max_health)

## Restores health to maximum health value.
func reset_health() -> void:
	health = max_health

func get_health_level() -> float:
	if max_health == 0:
		return 0.0
	return health / max_health * 100.0

func get_health_percentage() -> float:
	if max_health == 0:
		return 0.0
	return health / max_health
