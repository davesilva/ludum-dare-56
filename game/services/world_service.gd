extends GameService
class_name WorldService

var world_tile_map: TileMap = null
var spawn_points: Array = []
var players: Node2D = null
var WIDTH = 32
var HEIGHT = 18
var a_star = AStar2D.new()
var gameplay_spawn_root: Node2D = null

func initialize_a_star() -> void:
	var i = 0
	for y in range(0, HEIGHT):
		for x in range(0,WIDTH):
			a_star.add_point(i, Vector2(x, y))
			i += 1
	var max_idx = i
	for j in range(0, max_idx):
		if not ((j+1) % WIDTH == 0): # not right edge
			a_star.connect_points(j, j+1)
		if j < (WIDTH * (HEIGHT-1)): # bottom row
			a_star.connect_points(j, j+WIDTH)
	for p in a_star.get_points():
		var connected_points = a_star.get_point_connections(p)
#		print_debug(str(p) + " is connected to " + str(connected_points))
	# Add walls
	var wall_tiles = world_tile_map.get_used_cells_by_id(7)
	var walls = []
	for wt in wall_tiles:
		walls.append(tile_pos_to_idx(wt))
	for w in walls:
		remove_point(w)
		
	return

func connect_snake_signals(snake_head: SnakeHead) -> void:
	if not Game.events.snake.is_connected("completed_body_move", self, "_on_snake_completed_move"):
		Game.events.snake.connect("completed_body_move", self, "_on_snake_completed_move")
	
	# Uncomment for grid numbers
#	for p in a_star.get_points():
#		var point_label = Label.new()
#		point_label.text = str(p)
#		var p_tile_position = a_star.get_point_position(p)
#		var p_global_position = get_global_tile_position(p_tile_position)
#		point_label.set_global_position(p_global_position)
#		get_tree().root.add_child(point_label)
		

func remove_point(idx: int) -> void:
	var connected_points = a_star.get_point_connections(idx)
	for i in connected_points:
		a_star.disconnect_points(idx, i)
	a_star.remove_point(idx)
	
	
func get_spawn_root():
	if gameplay_spawn_root:
		return gameplay_spawn_root
	else:
		return get_tree().root
	

func get_global_tile_position(tile_position: Vector2) -> Vector2:
	if not world_tile_map:
		return Vector2.ZERO
		
	var local_tile_position = world_tile_map.map_to_world(tile_position)
	var cell_size = world_tile_map.cell_size
	var half_cell = cell_size / 2
	local_tile_position += half_cell
	return world_tile_map.to_global(local_tile_position)


func get_tile_position_from_global(global_position: Vector2) -> Vector2:
	if not world_tile_map:
		return Vector2.ZERO
	
	var local_position = world_tile_map.to_local(global_position)
	var cell_size = world_tile_map.cell_size
	var half_cell = cell_size / 2
	local_position -= half_cell
	return world_tile_map.world_to_map(local_position)
	
	
func place_object_at_tile_position(node_to_place: Node2D, tile_position: Vector2) -> void:
	var new_global_position = get_global_tile_position(tile_position)
	node_to_place.global_position = new_global_position
	
	
func get_random_tile_position() -> Vector2:
	var random_index = Random.randi_range(0, a_star.get_points().size() - 1)
	var random_point = a_star.get_points()[random_index]
	var random_tile_position = a_star.get_point_position(random_point)
	
	return random_tile_position
	
	
func get_random_tile_position_as_global() -> Vector2:
	var tile_position = get_random_tile_position()
	return get_global_tile_position(tile_position)
	

func _on_snake_completed_move() -> void:
	add_snake_to_astar()

func add_snake_to_astar() -> void:
	for a in a_star.get_points():
		if a_star.has_point(a):
			a_star.set_point_disabled(a, false)
	var snake_poses = Game.entity_service.get_snake_positions()
	for p in snake_poses:
		if a_star.has_point(tile_pos_to_idx(p)):
			a_star.set_point_disabled(tile_pos_to_idx(p))
	if snake_poses.size() == 1:
		var from_spot = (-1 * Game.entity_service.get_snake_direction()) + snake_poses[0]
		if a_star.has_point(tile_pos_to_idx(from_spot)):
			a_star.set_point_disabled(tile_pos_to_idx(from_spot))
		
func calculate_route_between_points(from: Vector2, to: Vector2) -> PoolVector2Array:
	var from_id = tile_pos_to_idx(from)
	var to_id = tile_pos_to_idx(to)
	var route =  a_star.get_point_path(from_id, to_id)
	return route

func find_valid_target(from: Vector2) -> PoolVector2Array:
	var from_id = tile_pos_to_idx(from)
	var corners = [
		tile_pos_to_idx(Vector2(0, 0)),
		tile_pos_to_idx(Vector2(WIDTH-1, 0)),
		tile_pos_to_idx(Vector2(WIDTH-1, HEIGHT-1)),
		tile_pos_to_idx(Vector2(0, HEIGHT-1))
	]
	var route = PoolVector2Array()
	for p in corners + a_star.get_points():
		if a_star.has_point(p) and not a_star.is_point_disabled(p) and not p == from_id:
			route = a_star.get_point_path(from_id, p)
			if not route.empty():
				return route
	return PoolVector2Array()


func tile_pos_to_idx(p: Vector2) -> int:
	return p.y * WIDTH + p.x

func check_tile_disabled(p: Vector2) -> bool:
	return a_star.is_point_disabled(tile_pos_to_idx(p))


#func destroy_all_enemies() -> void:
#	var enemies = get_tree().get_nodes_in_group(Game.groups.roots.enemy)
#	for enemy in enemies:
#		var true_enemy = enemy `as EnemyRoot
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
