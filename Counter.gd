extends Node
class_name Counter

signal tick(count)

@export var Timout: float = 0
@export var Interval: float = 0
@export var Enabled: bool = true
var TotalCount: float = 0
var Count: float = 0

var interval_counter: float = 0
var interval_ticks: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Count = 0
	TotalCount = 0

## Starts the counter and resets Count to 0 if reset_count == true(default), resets interval ticks and interval counter.
func start(reset_count: bool = true, reset_interval: bool = true):
	Enabled = true
	if reset_count:
		Count = 0
	if reset_interval:
		resetInterval()
	
## Resets and starts the counter setting Count = 0 and TotalCount = 0
func reset():
	Count = 0
	TotalCount = 0
	
func resetInterval():
	interval_counter = 0
	interval_ticks = 0

## Stops the counter
func stop():
	Enabled = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Enabled:
		if Count < Timout or Timout == 0:
			Count += delta
		else:
			Count = 0
		
#		Interval code
		if Interval != 0:
			if interval_counter > Interval:
				interval_counter += delta
			else:
				interval_counter = 0
				interval_ticks += 1
				tick.emit(interval_ticks)
		# Total Counter
		TotalCount += delta
