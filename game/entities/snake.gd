extends KinematicBody2D
class_name Snake

export (float) var speed = 3 # tiles per second

onready var tile_position = Vector2(5,2)
onready var current_direction = Vector2.RIGHT
onready var next_direction = Vector2.ZERO

var should_move = true

func _ready():
	_place_at_tile_position(tile_position)


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
	var next_tile_position = tile_position + _get_next_direction(true)
	var next_global_position = Game.world_service.get_global_tile_position(next_tile_position)
	var tween = create_tween()
	tween.tween_property(self, "global_position", next_global_position, 1.0 / speed)
	yield(tween, "finished")
	tile_position = next_tile_position
	current_direction = next_direction
	should_move = true
	
	
func _get_next_direction(allow_random_direction: bool = false) -> Vector2:
	if not allow_random_direction:
		return next_direction
		
	# only try to change 50% of the time
	if Random.roll_chance(50):
		return next_direction
		
	var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	directions.shuffle()
	var random_direction = directions[0]
	if random_direction + current_direction == Vector2.ZERO:
		return next_direction
	
	next_direction = random_direction
	return next_direction


func _place_at_tile_position(give_tile_position: Vector2) -> void:
	tile_position = give_tile_position
	var tile_global_position = Game.world_service.get_global_tile_position(tile_position)
	self.global_position = tile_global_position
	


