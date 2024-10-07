extends Node2D
class_name Bomb

export (Color) var black_color
export (Color) var red_color
export (Color) var white_color
export (PackedScene) var explosion_scene

onready var sprite: Sprite = $sprite

var flashes_remaining = 4

func _ready():
	sprite.self_modulate = black_color

func _on_flash_sequencer_new_value(value):
	if flashes_remaining > 3:
		sprite.self_modulate = red_color if value else black_color
	elif flashes_remaining == 3:
		$flash_sequencer.disable()
		$flash_sequencer.update_time_between_toggles(0.07)
		$flash_sequencer.enable()
		sprite.self_modulate = red_color	
	elif flashes_remaining < 3:
		sprite.self_modulate = white_color if value else red_color

	if value:
		flashes_remaining -= 1
		
	if flashes_remaining < 0:
		_place_explosion()
		queue_free()
		
		
func _place_explosion():
	var explosion_instance = explosion_scene.instance()
	var explosion_parent = Game.world_service.get_spawn_root()
	explosion_parent.add_child(explosion_instance)
	explosion_instance.global_position = self.global_position
	Game.camera_service.start_screen_shake(500, 0.3, 1000)
