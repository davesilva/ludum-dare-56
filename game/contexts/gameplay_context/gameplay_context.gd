extends Context
class_name GameplayContext

const CONTEXT_ID = "context.gameplay"
export (PackedScene) var snake_scene

onready var apple = $apple
#onready var gameplay_context_ui = $"Gameplay-Context-UI-Root/CanvasLayer/Gameplay-Context-UI"

func context_id_string() -> String:
	return CONTEXT_ID


func _ready():
	place_target()
	Game.events.snake.connect("target_captured", self, "_on_target_captured")
	Game.events.snake.connect("snake_doomed", self, "_on_snake_doomed")



func place_target() -> void:
	var new_tile_position = Game.world_service.get_random_tile_position()
	Game.world_service.place_object_at_tile_position(apple, new_tile_position)
	Game.events.game_round.emit_signal("new_target_placed", new_tile_position)


func _on_target_captured() -> void:
	place_target()

func _on_snake_doomed() -> void:
	var snake = Game.entity_service.get_snake_root_node()
	snake.queue_free()
	var snake_head_node = snake_scene.instance()
	self.add_child(snake_head_node)
