extends Pickup
class_name BombPickup

func _ready():
	add_to_group(Game.groups.roots.pickup_bomb)
	$pickup_hotbox.add_to_group(Game.groups.hotboxes.pickup_bomb)


func _on_pickup_hotbox_area_entered(area):
	if area.is_in_group(Game.groups.hotboxes.player_pickups):
		var random_tile_position = Game.world_service.get_random_tile_position()
		Game.world_service.place_object_at_tile_position(self, random_tile_position)
