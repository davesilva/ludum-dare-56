extends Node2D
class_name GameWorld

onready var tile_map: TileMap = $tile_map
onready var spawn_points: Node2D = $spawn_points
onready var players: Node2D = $players

func _ready():
	Game.world_service.world_tile_map = tile_map
	Game.world_service.spawn_points = spawn_points.get_children()
	Game.world_service.players = players
