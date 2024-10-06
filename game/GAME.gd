extends Node
# GAME
# This is the anchor for all the game systems

onready var groups: Groups = $groups
onready var events: Events = $events
onready var messages: Messages = $messages

onready var services = $services
onready var theme_service: ThemeService = $services/theme_service
onready var sound_service: SoundService = $services/sound_service
onready var pause_service: PauseService = $services/pause_service
onready var time_service: TimeService = $services/time_service
onready var screen_service: ScreenService = $services/screen_service
onready var camera_service: CameraService = $services/camera_service
onready var world_service: WorldService = $services/world_service
onready var entity_service: EntityService = $services/entity_service
onready var ui_service: UIPresentationService = $services/ui_service
onready var context_service: ContextPresentationService = $services/context_service

# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)
signal player_connected(id)
signal player_disconnected(id)

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 10567

# Max number of players.
const MAX_PEERS = 4

var peer = null

# Name for my player.
var player_name = "The Warrior"

# Names for remote players in id:name format.
var players = {}
var players_ready = []
var spawn_point_indices = {}
var colors = []

var has_been_initialized = false
var dedicated_server = false
var single_player = false

func _ready():
	initialize_services()
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	if "--server" in OS.get_cmdline_args():
		print("Dedicated server mode")
		dedicated_server = true
		host_game("Server")
	
func run_at(time_scale: float) -> TimeService.TimeBlock:
	return TimeService.TimeBlock.new(time_scale, time_service)


func resume_normal_time_scale() -> void:
	time_service.resume_normal_time_scale()
	
	
func is_paused() -> bool:
	return pause_service.is_paused()
	
	
func toggle_pause() -> void:
	pause_service.toggle_pause()
	

func pause_on() -> void:
	pause_service.pause_on()
	
	
func pause_off() -> void:
	pause_service.pause_off()


func initialize_services():
	var service_children = _get_services_children()
	for child in service_children:
		var service = child as GameService
		if not service or not service.is_running:
			continue
			
		service.on_game_initialize()
		
	has_been_initialized = true
	
	
func _process(delta):
	if not has_been_initialized:
		return
	
	if peer != null and not single_player:
		if get_tree().is_network_server():
			if peer.is_listening():
				peer.poll()
		else:
			if peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED or peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING:
				peer.poll()
	
	var service_children = _get_services_children()
	for child in service_children:
		var service = child as GameService
		if not service or not service.is_running:
			continue
			
		service.on_game_process(delta)
		
	if Input.is_action_just_pressed("toggle_pause"):
		pass
		
		
	
func _physics_process(delta):
	if not has_been_initialized:
		return
	
	var service_children = _get_services_children()
	for child in service_children:
		var service = child as GameService
		if not service or not service.is_running:
			continue
			
		service.on_game_physics_process(delta)
		

func _get_services_children() -> Array:
	if services.get_child_count() > 0:
		return services.get_children()
	else:
		return []


# Callback from SceneTree.
func _player_connected(id):
	emit_signal("player_connected", id)
	# Registration of a client beings here, tell the connected player that we are here.
	rpc_id(id, "register_player", player_name)


# Callback from SceneTree.
func _player_disconnected(id):
	var name = players[id]
	print("Player " + str(id) + " (" + name + ") disconnected")
	emit_signal("player_disconnected", id)
	unregister_player(id)
	if has_node("/root/MAIN/context_root/GameContext"): # Game is in progress.
		emit_signal("game_error", "Player " + name + " disconnected")
		print("Remaining players:")
		print(players)
		if get_tree().is_network_server() and players.size() < 1:
			print("Ending game...")
			end_game()



# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	# We just connected to a server
	emit_signal("connection_succeeded")


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")


# Lobby management functions.

remote func register_player(new_player_name):
	var id = get_tree().get_rpc_sender_id()
	print("Player connected: " + str(id))
	players[id] = new_player_name
	emit_signal("player_list_changed")


func unregister_player(id):
	players.erase(id)
	print("Player disconnected: " + str(id))
	emit_signal("player_list_changed")


remote func pre_start_game(spawn_point_indices, colors: Array):
	context_service.go_to(GameplayContext.CONTEXT_ID, false)
	var player_scene = load("res://game/entities/player/player.tscn")

	for p_id in spawn_point_indices:
		var spawn_point_index = spawn_point_indices[p_id]
		var spawn_pos = Game.world_service.spawn_points[spawn_point_index].position
		var player = player_scene.instance()

		player.set_name(str(p_id)) # Use unique ID as node name.
		player.spawn_point=spawn_pos
		player.position=spawn_pos
		player.set_network_master(p_id) #set unique id as master.
		player.set_player_color(colors[spawn_point_index])

		if p_id == get_tree().get_network_unique_id():
			# If node for this peer id, set name.
			player.set_player_name(player_name)
		else:
			# Otherwise set name from peer.
			player.set_player_name(players[p_id])

		Game.world_service.players.add_child(player)

	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()


remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!


remote func spawn_late_joiner(p_id, spawn_point_index, color):
	var player_scene = load("res://game/entities/player/player.tscn")
	var player = player_scene.instance()
	var spawn_pos = Game.world_service.spawn_points[spawn_point_index].position

	player.set_name(str(p_id)) # Use unique ID as node name.
	player.spawn_point=spawn_pos
	player.position=spawn_pos
	player.set_network_master(p_id) #set unique id as master.
	player.set_player_color(color)
	player.set_player_name(players[p_id])
	
	Game.world_service.players.add_child(player)


remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()


func begin_single_player_game():
	player_name = "Player"
	single_player = true
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(peer)
	begin_game()


func host_game(new_player_name):
	player_name = new_player_name
	peer = WebSocketServer.new()
	peer.listen(DEFAULT_PORT, PoolStringArray(), true)
	
	if not peer.is_listening():
		push_error("Server not listening - maybe port is in use?")
		peer = null
		Game.context_service.go_to(TitleContext.CONTEXT_ID)
		if dedicated_server:
			get_tree().quit(1)
	
	get_tree().set_network_peer(peer)


func join_game(ip, new_player_name):
	player_name = new_player_name
	peer = WebSocketClient.new()
	var url = "ws://" + ip + ":" + str(DEFAULT_PORT)
	var error = peer.connect_to_url(url, PoolStringArray(), true)
	get_tree().set_network_peer(peer)


func get_player_list():
	return players.values()


func get_player_name():
	return player_name


remote func begin_game():
	if not get_tree().is_network_server():
		rpc_id(1, "begin_game")
		return
	assert(get_tree().is_network_server())
	if context_service.current_context.context_id_string() == GameplayContext.CONTEXT_ID: # Game is in progress.
		var new_player_id = get_tree().get_rpc_sender_id()
		print("Player " + str(new_player_id) + " joined a game in progress")
		var spawn_point_idx = spawn_point_indices.values().max() + 1
		spawn_point_indices[new_player_id] = spawn_point_idx
		rpc_id(new_player_id, "pre_start_game", spawn_point_indices, colors)
		
		for p in players:
			if p != new_player_id:
				rpc_id(p, "spawn_late_joiner", new_player_id, spawn_point_idx, colors[spawn_point_idx])
		spawn_late_joiner(new_player_id, spawn_point_idx, colors[spawn_point_idx])
		return
	print("Starting game...")

	# Create a dictionary with peer id and respective spawn point index
	spawn_point_indices = {}
	var spawn_point_idx = 0
	if not dedicated_server:
		spawn_point_indices[1] = 0 # Server in spawn point 0.
		spawn_point_idx = 1
	
	for p in players:
		spawn_point_indices[p] = spawn_point_idx
		spawn_point_idx += 1
		
#	var colors = create_color_array(spawn_point_indices.size())
	colors = create_color_array(4)
	
	# Call to pre-start game with the spawn points.
	for p in players:
		rpc_id(p, "pre_start_game", spawn_point_indices, colors)

	pre_start_game(spawn_point_indices, colors)


func end_game():
	if context_service.current_context.context_id_string() == GameplayContext.CONTEXT_ID: # Game is in progress.
		context_service.go_to(TitleContext.CONTEXT_ID)

	emit_signal("game_ended")
	players.clear()
	
	
func create_color_array(number_of_colors: int) -> Array:
	var hue_value_separation = 1.0 / float(number_of_colors)
	var next_color = Random.color(0.5, 0.9)
	var color_array = []
	for index in number_of_colors:
		color_array.append(next_color)
		var next_hue = next_color.h + hue_value_separation
		if next_hue > 1.0:
			next_hue -= 1.0
				
		next_color = Color.from_hsv(next_hue, next_color.s, next_color.v)
	
	return color_array
