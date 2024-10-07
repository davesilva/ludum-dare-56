extends Context
class_name GameplayContext

const CONTEXT_ID = "context.gameplay"
export (PackedScene) var snake_scene

onready var apple = $apple

puppetsync var puppet_apple_global_position = Vector2.ZERO

func context_id_string() -> String:
	return CONTEXT_ID


func _ready():
	place_target()
	Game.events.snake.connect("target_captured", self, "_on_target_captured")
	Game.events.snake.connect("snake_doomed", self, "_on_snake_doomed")
	Game.events.player.connect("player_picked_up_apple", self, "_on_player_picked_up_apple")
	Game.connect("player_connected", self, "_on_player_connected")
	Game.connect("player_disconnected", self, "_on_player_disconnected")
	Game.camera_service.active_camera = $camera_2d


func _process(delta):
	if puppet_apple_global_position != apple.global_position:
		apple.global_position = puppet_apple_global_position


func place_target() -> void:
	if is_network_master():
		var new_tile_position = Game.world_service.get_random_tile_position()
		Game.world_service.place_object_at_tile_position(apple, new_tile_position)
		Game.events.game_round.emit_signal("new_target_placed", new_tile_position)
		puppet_apple_global_position = apple.global_position
		rset("puppet_apple_global_position", puppet_apple_global_position)


func _on_target_captured() -> void:
	place_target()
	

func _on_snake_doomed() -> void:
	rpc("_respawn_snake")
	
	
func _on_player_picked_up_apple() -> void:
	place_target()
	
func _on_player_connected(id) -> void:
	print('PLAYER CONNECTED')
	pass

func _on_player_disconnected(id) -> void:
	var player_nodes = Game.world_service.players.get_children()
	for player_node in player_nodes:
		if player_node.get_name() == str(id):
			player_node.queue_free()
	pass

puppetsync func _respawn_snake() -> void:
	var snake = Game.entity_service.get_snake_root_node()
	snake.queue_free()
	var snake_head_node = snake_scene.instance()
	self.add_child(snake_head_node)
