extends Node
class_name StateMachine

signal state_changed(current_state: String, next_state: String)
@export var default_state: String

var state: String = "":
	get():
		return state
		
	set(value):
		if value != state:
			if state_transition_guard(state, value):
				change_state(state, value)
				state_changed.emit(state, value)
				state = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state = default_state

func state_transition_guard(current_state: String, next_state: String) -> bool:
	if current_state:
		var current: State = get_state(current_state)
		if current.allow_all:
			return true
			
		elif current.use_state_guard_function:
			return current.state_guard(next_state)
			
		else:
			for state_name in current.allowed_states:
				if state_name == next_state:
					return true
			return false
	else:
		return true

func get_states() -> Dictionary[String, State]:
	var states : Dictionary[String, State]
	for child in get_children():
		if child is State:
			states[child.name] = child
	return states
	
func get_state(state_name: String) -> State:
	for child in get_children():
		if child is State and child.name == state_name:
			return child
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func change_state(current_state: String, next_state: String) -> void:
	var current: State = get_state(current_state)
	var next: State = get_state(next_state)
	if current:
		current.set_active(false, next_state)
	if next:
		next.set_active(true, current_state)
	
