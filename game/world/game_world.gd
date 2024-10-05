extends Node2D
class_name GameWorld

onready var tile_map: TileMap = $tile_map

func _ready():
	Game.world_service.world_tile_map = tile_map
