extends Context
class_name GameplayContext

const CONTEXT_ID = "context.gameplay"
export (PackedScene) var snake_scene

onready var apple = $apple
onready var player_apples_label: Label = $CanvasLayer/Control/Control/VBoxContainer/player_apples_label
onready var player_deaths_label: Label = $CanvasLayer/Control/Control/VBoxContainer/player_deaths_label
onready var snake_apples_label: Label = $CanvasLayer/Control/Control/VBoxContainer/snake_apples_label
onready var snake_deaths_label: Label = $CanvasLayer/Control/Control/VBoxContainer/snake_deaths_label
onready var win_overlay: Control = $CanvasLayer/Control/win_overlay
onready var lose_overlay: Control = $CanvasLayer/Control/lose_overlay

puppetsync var puppet_apple_global_position = Vector2.ZERO

func context_id_string() -> String:
	return CONTEXT_ID


func _ready():
	place_target()
	Game.events.snake.connect("target_captured", self, "_on_target_captured")
	Game.events.snake.connect("snake_doomed", self, "_on_snake_doomed")
	Game.events.player.connect("player_picked_up_apple", self, "_on_player_picked_up_apple")
	Game.events.game_round.connect("new_round_state_data", self, "_on_new_round_state_data")
	Game.connect("player_connected", self, "_on_player_connected")
	Game.connect("player_disconnected", self, "_on_player_disconnected")
	Game.camera_service.active_camera = $camera_2d
	
	win_overlay.visible = false
	lose_overlay.visible = false


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
	if is_network_master():
		rset_id(id, "puppet_apple_global_position", puppet_apple_global_position)


func _on_player_disconnected(id) -> void:
	var player_nodes = Game.world_service.players.get_children()
	for player_node in player_nodes:
		if player_node.get_name() == str(id):
			player_node.queue_free()
	

func _on_new_round_state_data(state_data: RoundState.RoundStateData) -> void:
	player_apples_label.text = "PLAYER APPLES: " + str(state_data.total_player_apples_acquired)
	player_deaths_label.text = "PLAYER DEATHS: " + str(state_data.total_player_deaths)
	snake_apples_label.text = "SNAKE APPLES: " + str(state_data.total_snake_apples_acquired)
	snake_deaths_label.text = "SNAKE DEATHS: " + str(state_data.total_snake_deaths)
	
	match state_data.status:
		RoundState.RoundStatus.MICE_WIN:
			win_overlay.visible = true
			lose_overlay.visible = false
		RoundState.RoundStatus.SNAKE_WIN:
			win_overlay.visible = false
			lose_overlay.visible = true
		RoundState.RoundStatus.IN_PROGRESS:
			win_overlay.visible = false
			lose_overlay.visible = false


puppetsync func _respawn_snake() -> void:
	var snake = Game.entity_service.get_snake_root_node()
	snake.reset()
	
