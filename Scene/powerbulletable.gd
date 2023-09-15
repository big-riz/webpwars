extends Area2D

@export var player = "Character"

func _on_body_entered(body):
	if body.name == player:
		body.powerBullet = true
		body.powerBullet_timer = 0
		self.queue_free()
		
func _ready():
	$PointLight2D/Timer.connect("timeout", _on_ColorTimer_timeout)
	$PointLight2D/Timer.start()

func _on_ColorTimer_timeout():
	var color = Color(randf(), randf(), randf())
	$PointLight2D.color = color
