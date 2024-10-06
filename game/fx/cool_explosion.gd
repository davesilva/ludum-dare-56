extends Node2D
class_name CoolExplosion

onready var debris: CPUParticles2D = $debris
onready var broad_smoke: CPUParticles2D = $broad_smoke
onready var central_smoke: CPUParticles2D = $central_smoke
onready var flash: AnimatedSprite = $flash

func _ready():	
	$damage_area/hitbox.add_to_group(Game.groups.hitboxes.explosion)
	
	debris.one_shot = true
	broad_smoke.one_shot = true
	central_smoke.one_shot = true
	flash.play("default")
	yield(Wait.on(self, 0.1), Wait.END)
	$damage_area.queue_free()
	# wait for smoke to clear
	yield(Wait.on(self, 7), Wait.END)
	queue_free()
