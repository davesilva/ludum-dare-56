extends KinematicBody2D
class_name Snake

export (float) var speed = 2 # tiles per second

onready var tile_position = Vector2(0, 0)
onready var current_direction = Vector2.RIGHT
onready var next_direction: Vector2

var should_move = true

func _process(delta):
	if should_move:
		move()
		
		
func _input(event):
	var input_vector = Vector2.ZERO
	
	if event.is_action_pressed("standard_move_up"):
		input_vector = Vector2.UP
	elif event.is_action_pressed("standard_move_right"):
		input_vector = Vector2.RIGHT
	elif event.is_action_pressed("standard_move_down"):
		input_vector = Vector2.DOWN
	elif event.is_action_pressed("standard_move_left"):
		input_vector = Vector2.LEFT
	else:
		return
		
	var is_opposite_direction = input_vector + current_direction == Vector2.ZERO
	if not is_opposite_direction:
		next_direction = input_vector
		
		
func move():
	should_move = false
	var next_tile_position = tile_position + next_direction
	var next_global_position = Game.world_service.get_global_tile_position(next_tile_position)
	var tween = create_tween()
	tween.tween_property(self, "global_position", next_global_position, 1.0 / speed)
	yield(tween, "finished")
	tile_position = next_tile_position
	current_direction = next_direction
	should_move = true




