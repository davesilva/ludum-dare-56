extends GameService
class_name WorldService

var world_tile_map: TileMap = null
var spawn_points: Array = []
var players: Node2D = null
#var top_most_world_node: Node2D = null

func get_global_tile_position(tile_position: Vector2) -> Vector2:
	if not world_tile_map:
		return Vector2.ZERO
		
	var local_tile_position = world_tile_map.map_to_world(tile_position)
	var cell_size = world_tile_map.cell_size
	var half_cell = cell_size / 2
	local_tile_position += half_cell
	return world_tile_map.to_global(local_tile_position)


#func destroy_all_enemies() -> void:
#	var enemies = get_tree().get_nodes_in_group(Game.groups.roots.enemy)
#	for enemy in enemies:
#		var true_enemy = enemy as EnemyRoot
#		if true_enemy:
#			true_enemy.call_deferred("die", false)
#
#
#func destroy_all_bullets() -> void:
#	var bullets = get_tree().get_nodes_in_group(Game.groups.roots.bullet)
#	for bullet in bullets:
#		var true_bullet = bullet as Bullet
#		if true_bullet:
#			true_bullet.call_deferred("die", false)
