extends Node
class_name RoundState
# this is where we track whats going on in the game

const KEY_PLAYER_APPLE = "round.state.key.player.apple"
const KEY_PLAYER_DEATHS = "round.state.key.player.deaths"
const KEY_SNAKE_APPLES = "round.state.key.snake.apples"
const KEY_SNAKE_DEATHS = "round.state.key.snake.deaths"

class RoundStateData:
	var total_player_apples_acquired = 0
	var total_player_deaths = 0
	var total_snake_apples_acquired = 0
	var total_snake_deaths = 0
	
var data = RoundStateData.new()

static func create_dictionary_from_data(p_data: RoundStateData) -> Dictionary:
	return {
		KEY_PLAYER_APPLE: p_data.total_player_apples_acquired, 
		KEY_PLAYER_DEATHS: p_data.total_player_deaths, 
		KEY_SNAKE_APPLES: p_data.total_snake_apples_acquired,
		KEY_SNAKE_DEATHS: p_data.total_snake_deaths
	}
	
	
static func create_data_from_dictionary(dict: Dictionary) -> RoundStateData:
	var new_data = RoundStateData.new()
	new_data.total_player_apples_acquired = dict[KEY_PLAYER_APPLE]
	new_data.total_player_deaths = dict[KEY_PLAYER_DEATHS]
	new_data.total_snake_apples_acquired = dict[KEY_SNAKE_APPLES]
	new_data.total_snake_deaths = dict[KEY_SNAKE_DEATHS]
	
	return new_data


func _ready():
	Game.events.snake.connect("target_captured", self, "_on_target_captured")
	Game.events.snake.connect("snake_died", self, "_on_snake_died")
	Game.events.player.connect("player_picked_up_apple", self, "_on_player_picked_up_apple")
	Game.events.player.connect("player_died", self, "_on_player_died")
	
	
func _on_target_captured():
	data.total_snake_apples_acquired += 1
	broadcast_latest()
	

func _on_snake_died():
	data.total_snake_deaths += 1
	broadcast_latest()
	

func _on_player_picked_up_apple():
	data.total_player_apples_acquired += 1 
	broadcast_latest()
	

func _on_player_died():
	data.total_player_deaths += 1
	broadcast_latest()
	
	
func broadcast_latest():
	if is_network_master():
		var dictionary = create_dictionary_from_data(data)
		rpc("_broadcast_latest", dictionary)
	
	
puppetsync func _broadcast_latest(p_data_dictionary: Dictionary) -> void:
	var new_data = create_data_from_dictionary(p_data_dictionary)
	data = new_data
	Game.events.game_round.emit_signal("new_round_state_data", data)
