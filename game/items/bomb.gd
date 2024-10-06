extends Node2D
class_name Bomb

export (Color) var black_color
export (Color) var red_color
export (Color) var white_color

onready var sprite: Sprite = $sprite

var flashes_remaining = 10

func _ready():
	sprite.self_modulate = black_color

func _on_flash_sequencer_new_value(value):
	if flashes_remaining > 5:
		sprite.self_modulate = red_color if value else black_color
	elif flashes_remaining == 5:
		$flash_sequencer.disable()
		$flash_sequencer.update_time_between_toggles(0.07)
		$flash_sequencer.enable()
		sprite.self_modulate = red_color	
	elif flashes_remaining < 5:
		sprite.self_modulate = white_color if value else red_color

	if value:
		flashes_remaining -= 1
		
	if flashes_remaining < 0:
		queue_free()
