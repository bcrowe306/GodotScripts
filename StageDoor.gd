@tool
extends Area2D

class_name StageDoor

@export var next_stage: String = ""

var stage: Stage = null

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if next_stage == "":
		warnings.append("next_stage is not assigned.")
	return warnings


func _ready() -> void:
	# get reference to the current stage and warn if not found
	stage = get_parent() as Stage
	if not stage: 
		push_warning("StageDoor is not a child of a Stage node.")

	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is PlayerController:
		if next_stage != "" and stage and stage.level:
			var level: Level = stage.level
			level.load_stage(next_stage)
		else:
			push_warning("StageDoor cannot transition: next_stage is empty or stage/level reference is missing.")
