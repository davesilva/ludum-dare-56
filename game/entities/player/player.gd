extends KinematicBody2D
class_name Player

export (PackedScene) var bomb_scene

const SPEED = 100.0

puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()
var spawn_point = Vector2()

onready var hurtbox: TriggerZone = $hurtbox

var player_name = "Player"
var speed_boost_direction = Vector2.ZERO
var has_bomb = false

func _ready():
	puppet_pos = position
	Game.events.snake.connect("caught_player", self, "_have_been_caught")
	add_to_group(Game.groups.roots.player_character)
	hurtbox.add_to_group(Game.groups.hurtboxes.player)


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
			
		if Input.is_action_just_pressed("ui_accept") and has_bomb:
			_place_bomb()
			
		motion = motion.normalized()
		if speed_boost_direction != Vector2.ZERO:
			motion = speed_boost_direction * 3

		rset("puppet_motion", motion)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		motion = puppet_motion
	
	$wave_sequencer.enabled = motion != Vector2.ZERO
	if motion != Vector2.ZERO:
		$body_sprite.scale.x = -1 if motion.x < 0 else 1		

	move_and_slide(motion * SPEED)
	if not is_network_master():
		puppet_pos = position # To avoid jitter


func set_player_name(name):
	player_name = name
	

func set_player_color(color: Color):
	$body_sprite.self_modulate = color


func _have_been_caught(body):
	if body == self:
		_respawn()
			

func _respawn():
	if is_network_master():
		position = spawn_point
		rset("puppet_motion", Vector2())
		rset("puppet_pos", position)
		
			
func _place_bomb():
	rpc("_place_bomb_at_position", global_position)
	has_bomb = false
	
	
remotesync func _place_bomb_at_position(position: Vector2) -> void:
	var bomb_instance = bomb_scene.instance()
	var bomb_parent = Game.world_service.get_spawn_root()
	bomb_parent.add_child(bomb_instance)
	bomb_instance.global_position = global_position
	
	
func _on_wave_sequencer_new_value(value):
	$body_sprite.rotation_degrees = value


func _on_pickup_hotbox_area_entered(area):
	if area.is_in_group(Game.groups.hotboxes.pickup_apple):
		Game.events.player.emit_signal("player_picked_up_apple")
	elif area.is_in_group(Game.groups.hotboxes.pickup_bomb):
		has_bomb = true
		print("picked up bomb")
	elif area.is_in_group(Game.groups.hotboxes.speed_pad):
		var speed_pad = TriggerZone.get_owner_from(area)
		if speed_pad:
			var pad_rotation = ((speed_pad) as Node2D).rotation_degrees
			var pad_rad = deg2rad(pad_rotation)
			var direction = Vector2.RIGHT.rotated(pad_rad)
			_trigger_speed_boost(direction)


func _on_hurtbox_area_entered(area):
	if area.is_in_group(Game.groups.hitboxes.explosion):
		print("player killed by bomb")
		_respawn()
		
	
func _trigger_speed_boost(direction: Vector2):
	speed_boost_direction = direction
	var original_wave_time = $wave_sequencer.min_to_max_time
	$wave_sequencer.min_to_max_time = original_wave_time * 0.3
	yield(Wait.on(self, 1.0), Wait.END)
	$wave_sequencer.min_to_max_time = original_wave_time
	speed_boost_direction = Vector2.ZERO
	
