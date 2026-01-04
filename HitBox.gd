extends Area2D
class_name HitBox

## Emitted when this hitbox successfully hits a target for the first time.
signal hit_registered(target: Node)

## Tracks all targets that have been hit during the current attack to prevent duplicate hits.
var hit_log: Array[Node] = []

var hit_vector: Vector2 = Vector2.ZERO

## Reference to the parent Attack node, if any.
var parent_attack: Attack = null

## Reference to all CollisionShape2D children for quick access.
var collision_shapes: Array[CollisionShape2D] = []

## Override to perform any setup when the node is added to the scene.
func _on_ready() -> void:
	pass


## Override to handle per-frame logic.
func _on_process(_delta: float) -> void:
	pass

func _ready() -> void:
	self.area_entered.connect(self._on_area_entered)
	self.body_entered.connect(self._on_body_entered)
	self.area_exited.connect(self._on_area_exited)
	
	# Get reference to parent Attack if it exists
	var parent = get_parent()
	if parent is Attack and parent.has_signal("attack_started"):
		parent_attack = parent
		parent_attack.attack_started.connect(_on_attack_started)
		parent_attack.attack_finished.connect(_on_attack_finished)

	
	# Gather all collision shapes
	_gather_collision_shapes()
	
	# Disable collision shapes by default
	if parent_attack and parent_attack is Attack and parent_attack.auto_enable:
		enable_hitbox()
	else:
		disable_hitbox()

	_on_ready()
	
	

func _process(_delta: float) -> void:
	_on_process(_delta)

## Gathers all CollisionShape2D children and stores them for quick access.
func _gather_collision_shapes() -> void:
	collision_shapes.clear()
	for child in get_children():
		if child is CollisionShape2D:
			collision_shapes.append(child)

## Enables all child CollisionShape2D nodes, making the hitbox active.
func enable_hitbox() -> void:
	for shape in collision_shapes:
		if shape:
			shape.set_deferred("disabled", false)

## Disables all child CollisionShape2D nodes, making the hitbox inactive.
func disable_hitbox() -> void:
	for shape in collision_shapes:
		if shape:
			shape.set_deferred("disabled", true)

## Clears the hit log when a new attack starts and enables the hitbox.
func _on_attack_started() -> void:
	clear_hit_log()
	enable_hitbox()

## Disables the hitbox when the attack finishes.
func _on_attack_finished() -> void:
	disable_hitbox()

## Clears all entries from the hit log, allowing targets to be hit again.
func clear_hit_log() -> void:
	hit_log.clear()

## Checks if a target has already been hit during this attack.
func has_hit_target(target: Node) -> bool:
	return target in hit_log

## Adds a target to the hit log.
func register_hit(target: Node) -> void:
	if target and not has_hit_target(target):
		hit_log.append(target)
		hit_registered.emit(target)

func _on_area_exited(area: Area2D) -> void:
	# Remove the target from hit log when they exit the hitbox area
	if has_hit_target(area):
		hit_log.erase(area)

func _on_area_entered(area: Area2D) -> void:
	# Check if we've already hit this target
	if has_hit_target(area):
		return
	
	# Check if the area is a HurtBox
	if not area is HurtBox:
		return
	
	# Check if we have a valid parent attack
	if not parent_attack:
		return
	
	# Call the take damage function of the HurtBox, passing the parent Attack
	var hurtbox = area as HurtBox
	if hurtbox and hurtbox.has_method("takeDamage") and hurtbox.monitoring:

		# Register the hit
		register_hit(area)
		if parent_attack.has_signal("attack_successful_hit"):
			parent_attack.attack_successful_hit.emit(parent_attack, hit_vector)
		hurtbox.takeDamage(parent_attack, hit_vector)

func _on_body_entered(body: Node2D) -> void:
	# Check if we've already hit this target
	if has_hit_target(body):
		return
	
	# TODO: Implement body hit logic here
	pass

## Calculates the damage dealt by this hitbox based on attack properties.
func calculate_damage() -> float:
	# powerups multiply damage
	return parent_attack.damage * parent_attack.power
