extends KinematicBody2D
class_name Player

const SPEED = 250.0

puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()
var spawn_point = Vector2()

var player_name = "Player"

func _ready():
	puppet_pos = position
	Game.events.snake.connect("caught_player", self, "_have_been_caught")

func _physics_process(_delta):
	var motion = Vector2()

	if is_network_master():
		if Input.is_action_pressed("standard_move_left"):
			motion += Vector2(-1, 0)
		if Input.is_action_pressed("standard_move_right"):
			motion += Vector2(1, 0)
		if Input.is_action_pressed("standard_move_up"):
			motion += Vector2(0, -1)
		if Input.is_action_pressed("standard_move_down"):
			motion += Vector2(0, 1)

		rset("puppet_motion", motion)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		motion = puppet_motion
	
	move_and_slide(motion * SPEED)
	if not is_network_master():
		puppet_pos = position # To avoid jitter


func set_player_name(name):
	player_name = name
	

func set_player_color(color: Color):
	$body_sprite.self_modulate = color

func _have_been_caught(body):
	if is_network_master():
		if body == self:
			position = spawn_point
			rset("puppet_motion", Vector2())
			rset("puppet_pos", position)
