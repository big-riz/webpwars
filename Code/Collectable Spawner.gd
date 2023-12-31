extends CollisionShape2D

@export var Coin: PackedScene
var coinage
@export var PowerUp: PackedScene
@export var PowerUpBullet: PackedScene
@export var power_spawn_rate = 5
var power_timer = 0


func _ready():
	var temp = Coin.instantiate()
	temp.position = self.position + (Vector2(randi_range(-400, 400), randi_range(-400, 400)))
	add_sibling.call_deferred(temp)
	coinage = temp
	
func _process(delta):
	power_timer += delta
	
	if power_timer >= power_spawn_rate:
		power_timer = 0
		if (randf() > 0.5):
			var temp = PowerUp.instantiate()
			temp.position = self.position + (Vector2(randi_range(-400, 400), randi_range(-400, 400)))
			add_sibling.call_deferred(temp)
		else:
			var temp = PowerUpBullet.instantiate()
			temp.position = self.position + (Vector2(randi_range(-400, 400), randi_range(-400, 400)))
			add_sibling.call_deferred(temp)
	
	if coinage == null:
		_ready()
