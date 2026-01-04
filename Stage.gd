@tool
extends Node2D

class_name Stage

@export var stage_name: String = ""
@export var spawn_point: Marker2D = null
@export var checkpoints: Array[Marker2D] = []
var last_checkpoint_index: int = -1

var level: Level = null

func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = PackedStringArray()
    if stage_name == "":
        warnings.append("stage_name is not assigned.")

    if not spawn_point:
        warnings.append("spawn_point is not assigned.")
    return warnings

func _ready() -> void:
    level = get_parent() as Level
    if level:
        print_debug("Stage '%s' is part of Level '%s'" % [stage_name, level.level_name])
    else:
        push_warning("Stage '%s' is not part of any Level." % stage_name)

func get_player_spawn_position() -> Vector2:
    if last_checkpoint_index >= 0 and last_checkpoint_index < checkpoints.size():
        return checkpoints[last_checkpoint_index].position
    elif spawn_point:
        return spawn_point.position
    else:
        push_warning("No valid spawn point found in stage '%s'." % stage_name)
        return Vector2.ZERO
