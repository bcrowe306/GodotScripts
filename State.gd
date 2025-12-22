extends Node

## State base class for use in StateMachine
class_name State

var timeout_finished: bool = false

signal timeout_reached()

## Allows all transitions from this state if true
@export var allow_all: bool = true

## List of allowed states to transition to from this state. Ignored if allow_all is true
@export var allowed_states: Array[String] = []

## References to commonly used Animation nodes in a state
@export var animated_sprite: AnimatedSprite2D

## The animation name to play when this state is active
@export var animation_name: String

## Reference to an external Timer node for additional timeout functionality
@export var timer: Timer

## Reference to an AudioStreamPlayer node for playing audio in this state
@export var audio_stream: AudioStreamPlayer

## Reference to an AnimationPlayer node for more complex animations
@export var animation_player: AnimationPlayer

## If true, uses the state_guard function to determine if a transition is allowed
@export var use_state_guard_function: bool = false

## Duration in seconds before timeout_reached signal is emitted. 0.0 means no timeout
@export var timeout_duration: float = 0.0

## If true, the timeout timer will only run once per state entry
@export var timer_onshot: bool = true

var state_duration: float = 0.0
var timer_counter: float = 0.0

var state_machine: StateMachine

func _ready():
	var sm = get_parent()
	if sm is StateMachine:
		state_machine = sm
	timeout_reached.connect(self._on_timeout)
	_on_ready()

## Override this method for _ready calls
func _on_ready():
	pass

# Override this method for _process calls
func _update(_delta: float):
	pass

## Override: Called when the state is entering
func _enter(_previous_state: String):
	pass
	
## Override: Called when the state is exiting
func _exit(_next_state: String):
	pass

## Override: Called when the timer times out. Timeout
func _on_timeout():
	pass

# -------- Internal Methods ---------
var active: bool = false:
	get():
		return active
		
	set(value):
		if value != active:
			active = value

func set_active(value: bool, state_name: String):
	active = value
	if active:
		state_duration = 0.0
		timer_counter = 0.0
		timeout_finished = false
		_enter(state_name)
	else:
		_exit(state_name)

func state_guard(_next_state: String) -> bool:
	return true

func _process(delta: float) -> void:
	if active:
		state_duration += delta
		timer_counter += delta
		if timeout_finished == false and timeout_duration > 0.0 and timer_counter >= timeout_duration:
			timeout_reached.emit()
			if timer_onshot:
				
				timeout_finished = true
			else:
				timeout_finished = false
				timer_counter = 0.0
		_update(delta)
