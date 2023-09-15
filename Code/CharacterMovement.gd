extends CharacterBody2D

const SPEED = 300.0
@export var Bullet: PackedScene
@export var PowerBullet: PackedScene
@onready var Camera = get_node("Camera2D")
@export var fire_rate = 0.2
var actual_rate = 0.2
var timer = 0
var powerBullet = false
var power = false
var power_timer = 0
var powerBullet_timer = 0
@onready var absolute_parent = get_parent()

# controls the player's movement when they die.
var die: bool = false

func get_parameter_value(parameters, key):
	var pairs = parameters.split("&") if parameters else []
	for pair in pairs:
		var key_value = pair.split("=")
		if key_value.size() == 2 and key_value[0] == key:
			return key_value[1]
	return ""



func _on_Viewport_size_changed():
	$Sprite2D.texture.width = get_viewport_rect().size.x
	$Sprite2D.texture.height = get_viewport_rect().size.y * 1.3
	var base_size = Vector2(1920, 1920)
	var scale_x = get_viewport_rect().size.x / base_size.x
	var scale_y = get_viewport_rect().size.y*1.3 / base_size.y
	($Sprite2D.texture as GradientTexture2D).fill_to = Vector2(0.2 * scale_x + 0.1, 0.2 * scale_y + 0.1)
	
	
func _ready():
	get_viewport().connect("size_changed",_on_Viewport_size_changed)
	$Sprite2D.texture.width = get_viewport_rect().size.x
	$Sprite2D.texture.height = get_viewport_rect().size.y*1.3
	var base_size = Vector2(1920, 1920)
	var scale_x = get_viewport_rect().size.x / base_size.x
	var scale_y = get_viewport_rect().size.y*1.3 / base_size.y
	($Sprite2D.texture as GradientTexture2D).fill_to = Vector2(0.2 * scale_x + 0.1, 0.2 * scale_y + 0.1)
	# I have no idea why this makes the camera do that thing, but this is cool!
	Camera.set("position", Vector2(100, 0))
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)

	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var string = JavaScriptBridge.eval("getURLParameters()")
	var url_parameters = JSON.parse_string(string if string else "null")
	var inscription_id = get_parameter_value(url_parameters, "inscription")
	var base_url = "https://turbo.ordinalswallet.com/inscription/content/"
	var full_url = base_url + inscription_id
	
	var error = http_request.request(full_url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Image couldn't be downloaded. Try a different image.")

	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")

	var texture = ImageTexture.create_from_image(image)

	# Display the image in a TextureRect node.
	#var texture_rect = TextureRect.new()
	self.get_node("MeshInstance2D").texture = texture
	#texture_rect.texture = texture
	
	
func _process(delta):
	$Sprite2D.global_position = $Camera2D.get_screen_center_position()
	$Sprite2D.global_rotation = 0
	
	
func _physics_process(delta):

	timer += delta
	# Power up that you can get :D
	if power == true:
		power_timer += delta
		actual_rate = fire_rate / 2
		if power_timer >= 10:
			power = false
	else:
		actual_rate = fire_rate
		power_timer = 0
	
	if powerBullet == true:
		powerBullet_timer += delta
		if powerBullet_timer >= 10:
			powerBullet = false
	else:
		powerBullet_timer = 0
	
	# Get the input direction and handle the movement/deceleration.
	var direction_x = Input.get_axis("Left", "Right")
	var direction_y = Input.get_axis("Up", "Down")
	velocity.x = 0
	velocity.y = 0
	
	# Stop doing things if you are dead, Respawn on 
	if die == true:
		if Input.get_action_raw_strength("Respawn"):
			Respawn()
		return
	
	# if the player isn't dead...
	if Input.get_action_raw_strength("Shoot") && timer >= actual_rate:
		var temp
		if (powerBullet == true):
			temp = PowerBullet.instantiate()
		else:
			temp = Bullet.instantiate()
		add_sibling(temp)
		temp.global_position = get_node("BulletSpawn").get("global_position")
		# this sets the rotation as to where it will fire
		temp.set("area_direction", (get_global_mouse_position() - self.global_position).normalized())
		# These statements below handle camera shake
		Camera.set("offset", Vector2(randf_range(-4, 4), randf_range(-4, 4)))
		timer = 0
	else:
		Camera.set("offset", Vector2(0, 0))
	# movement is handled like this
	if direction_x:
		velocity.x = direction_x * SPEED
	if direction_y:
		velocity.y = direction_y * SPEED
		
	# look at mouse
	self.look_at(get_global_mouse_position())
	
	move_and_slide()

# all the things that it do when you die.
func Die():
	get_node("Explosive").set_emitting(true)
	get_node("Explosive/Sound").play()
	self.get_node("MeshInstance2D").set("visible", false)
	#Stop Camera and set player to death
	Camera.set("position", Vector2(0, 0))
	die = true
	#Wait 1.5 seconds before showing retry screen
	await get_tree().create_timer(1.5).timeout
	#Move Camera to center
	position = Vector2(383,397)
	#Show Retry Background over whole screen
	$"../Retry".show()
	
# Reload Scene
func Respawn():
	get_tree().reload_current_scene()
