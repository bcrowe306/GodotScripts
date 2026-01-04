extends Node2D
class_name Attack


var test: AudioStream
## Emitted when the attack is executed.
signal attack_started

## Emitted when the attack has completed its recovery time.
signal attack_finished

signal attack_successful_hit(attack: Attack, hit_vector: Vector2)

signal recovery_completed

## The name of this attack (e.g., "Jab", "Heavy Slash", "Fireball").
@export var attack_name: String = "Basic Attack"

## If true, the attack automatically enables its hitboxes on ready.
@export var auto_enable: bool = false

## The amount of damage this attack deals.
@export_range(0.0, 1000.0, 0.5) var damage: float = 10.0

## The knockback amount applied to targets hit by this attack.
@export_range(0, 1.0, 0.01) var knockback: float = 0.0

## Duration in seconds that the game freezes on hit for impact effect.
@export_range(0.0, 1.0, 0.01) var hitstop: float = 0.1

## Intensity of camera shake when the attack hits a target.
@export_range(0.0, 1.0, 0.01) var camera_shake	: float = 0.2

## Time in seconds before the attacker can perform another action after this attack.
@export_range(0.0, 5.0, 0.05) var recovery_time: float = 0.5

## If true, attack sounds play automatically when the attack is launched.
@export var play_sounds_on_attack: bool = true

@export var hit_vector: Vector2 = Vector2.ZERO

## Reference to all hitboxes that are children of this attack.
var hitboxes: Array[HitBox] = []

## Reference to all audio players that are children of this attack.
var audio_players: Array[AudioStreamPlayer2D] = []

## Tracks if the attack is currently active.
var is_active: bool = false

## Timer for recovery period.
var recovery_timer: float = 0.0

var damage_multiplier: float = 1.0

## Override to perform any setup when the node is added to the scene.
func _on_ready() -> void:
	pass


## Override to handle per-frame logic.
func _on_process(_delta: float) -> void:
	pass

func _ready() -> void:
	_gather_hitboxes()
	_gather_audio_players()
	_on_ready()

func _process(delta: float) -> void:
	if is_active and recovery_timer > 0:
		recovery_timer -= delta
		if recovery_timer <= 0:
			recovery_completed.emit()
			recovery_timer = 0.0
	_on_process(delta)

## Gathers all HitBox children and stores them for quick access.
func _gather_hitboxes() -> void:
	hitboxes.clear()
	for child in get_children():
		if child is HitBox:
			hitboxes.append(child)

## Gathers all AudioStreamPlayer2D children and stores them for quick access.
func _gather_audio_players() -> void:
	audio_players.clear()
	for child in get_children():
		if child is AudioStreamPlayer2D:
			audio_players.append(child)

## Executes the attack by activating all child HitBoxes.
## This method can be overridden in derived classes for custom attack behavior.
func do_attack(vector: Vector2=Vector2.ZERO, multiplier: float=1.0) -> void:
	if is_active:
		return
	
	self.damage_multiplier = multiplier
	is_active = true
	recovery_timer = recovery_time
	attack_started.emit()

	# Activate all hitboxes
	for hitbox in hitboxes:
		_activate_hitbox(hitbox, vector)

	# Play attack sounds if enabled
	if play_sounds_on_attack:
		play_attack_sounds()
	

func is_recovery_complete() -> bool:
	return recovery_timer <= 0.0

## Activates a single hitbox. Can be overridden for custom hitbox activation logic.
func _activate_hitbox(hitbox: HitBox, vector: Vector2) -> void:
	if hitbox:
		hitbox.hit_vector = vector
		hitbox.monitoring = true

## Plays all AudioStreamPlayer2D children. Can be called manually or automatically on attack.
func play_attack_sounds() -> void:
	
	for audio_player in audio_players:
		
		if audio_player and audio_player.stream:
			audio_player.play()

## Deactivates all hitboxes.
func _deactivate_hitboxes() -> void:
	for hitbox in hitboxes:
		if hitbox:
			hitbox.set_deferred("monitoring", false)

## Called when the attack finishes its recovery period.
func finish_attack() -> void:
	is_active = false
	_deactivate_hitboxes()
	attack_finished.emit()

## Manually cancel the attack and reset state.
func cancel_attack() -> void:
	is_active = false
	recovery_timer = 0.0
	_deactivate_hitboxes()
	attack_finished.emit()
