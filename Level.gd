@tool 
extends Node2D

class_name  Level

signal stage_loaded(stage_name: String)
signal player_spawned(player: Node2D)

@export var level_name: String = "Level"
@export_file("*.tscn") var player : String = ""

@export var stages: Dictionary[String, Resource]
@export var initial_stage: String = ""

var current_stage: String = ""
var current_stage_instance: Stage = null
var stage_scenes: Dictionary[String, PackedScene] = {}

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if level_name == "":
		warnings.append("level_name is not assigned.")
	if stages.size() == 0:
		warnings.append("No stages have been assigned to this level.")
	if initial_stage == "":
		warnings.append("initial_stage is not assigned.")
	elif not (initial_stage in stages):
		warnings.append("initial_stage '%s' is not found in the stages dictionary." % initial_stage)
	return warnings


func _ready() -> void:
	for stage_name in stages:
		var packed_scene: PackedScene = ResourceLoader.load(stages[stage_name].resource_path) as PackedScene
		if packed_scene:
			stage_scenes[stage_name] = packed_scene
		else:
			push_error("Failed to load stage scene: %s" % stage_name)
	print_debug("Loaded %d stages for level: %s" % [stage_scenes.size(), level_name])

	if initial_stage != "":
		load_stage(initial_stage)
	else:
		push_warning("initial_stage is not assigned; no stage loaded on ready.")


func load_stage(stage_name: String) -> void:

	if stage_name in stage_scenes:

		# Clear existing children
		for child in get_children():
			child.queue_free()
		
		# Instance and add the new stage    
		current_stage_instance = stage_scenes[stage_name].instantiate() as Stage
		add_child(current_stage_instance)
		current_stage = stage_name
		stage_loaded.emit(stage_name)
		print_debug("Loaded stage %s for level: %s" % [stage_name, level_name])

		load_player()

	else:
		push_error("Stage name '%s' not found in level: %s" % [stage_name, level_name])



func load_player():
	if player != "":
		var player_scene: PackedScene = ResourceLoader.load(player) as PackedScene
		if player_scene:
			var player_instance: PlayerController = player_scene.instantiate() as PlayerController
			add_child(player_instance)
			player_instance.position = current_stage_instance.get_player_spawn_position()
			player_spawned.emit(player_instance)
			print_debug("Player instance added to level: %s" % level_name)
		else:
			push_error("Failed to load player scene: %s" % player)
	else:
		push_warning("Player scene is not assigned for level: %s" % level_name)
