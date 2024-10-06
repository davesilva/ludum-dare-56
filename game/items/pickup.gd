extends Node2D
class_name Pickup

func _ready():
	add_to_group(Game.groups.types.pickup)
