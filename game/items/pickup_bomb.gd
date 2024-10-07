extends Pickup
class_name BombPickup

func _ready():
	add_to_group(Game.groups.roots.pickup_bomb)
	$pickup_hotbox.add_to_group(Game.groups.hotboxes.pickup_bomb)
	Game.events.player.connect("player_picked_up_apple", self, "_on_player_picked_up_apple")


func _on_pickup_hotbox_area_entered(area):
#	if area.is_in_group(Game.groups.hotboxes.player_pickups):
	pass


func _get_picked_up():
	var random_tile_position = Game.world_service.get_random_tile_position()
	Game.world_service.place_object_at_tile_position(self, random_tile_position)
	$sprite.visible = false
	$pickup_hotbox.monitorable = false
	$pickup_hotbox.monitoring = false


func _on_player_picked_up_apple():
	$sprite.visible = true
	$pickup_hotbox.monitorable = true
	$pickup_hotbox.monitoring = true
