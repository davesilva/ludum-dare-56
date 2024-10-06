extends Pickup
class_name Apple

func _ready():
	add_to_group(Game.groups.roots.apple)
	$pickup_hotbox.add_to_group(Game.groups.hotboxes.pickup_apple)


func _on_wave_sequencer_new_value(value):
	$sprite.offset.y = value
