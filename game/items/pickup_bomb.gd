extends Pickup
class_name BombPickup

func _ready():
	add_to_group(Game.groups.roots.pickup_bomb)
	$pickup_hotbox.add_to_group(Game.groups.hotboxes.pickup_bomb)
