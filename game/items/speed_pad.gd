extends Node2D
class_name SpeedPad

func _ready():
	add_to_group(Game.groups.types.environment)
	add_to_group(Game.groups.roots.player_character)
	$hotbox.add_to_group(Game.groups.hotboxes.speed_pad)
