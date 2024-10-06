extends Node2D
class_name CoolExplosion

onready var debris: CPUParticles2D = $debris
onready var broad_smoke: CPUParticles2D = $broad_smoke
onready var central_smoke: CPUParticles2D = $central_smoke
onready var flash: AnimatedSprite = $flash

func _ready():	
	debris.one_shot = true
	broad_smoke.one_shot = true
	central_smoke.one_shot = true
	flash.play("default")
	# wait for smoke to clear
	yield(Wait.on(self, 12), Wait.END)
	queue_free()
