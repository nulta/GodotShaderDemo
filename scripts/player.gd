extends CharacterBody3D

@onready var _camera = $CameraSpot
@onready var _world = %WorldEnvironment
const speed = 8.0  # meters per second
const gravity = 9.8 * 1.1  # meters per second^2
const jump_vector = Vector3(0, 6, 0)
const mouse_sensitivity = 0.00001

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var is_idle = true
	
	# camera movement
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mouse = Input.get_last_mouse_velocity() * mouse_sensitivity * -1.0
		_camera.rotation.y += mouse.x
		_camera.rotation.x += mouse.y
		
		#var mouse_wheel = Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN)

	# move vector
	var movement = Input.get_vector("move_backward", "move_forward", "move_left", "move_right")
	movement = movement.normalized()

	# Player movement vector
	var target_velocity = Vector3(movement.y, 0, -movement.x) * speed
	target_velocity = target_velocity.rotated(Vector3.UP, rotation.y)
	velocity.x = target_velocity.x
	velocity.z = target_velocity.z
	
	# moved?
	var moved = target_velocity.length_squared() > 0.1
	if moved:
		rotation.y += _camera.rotation.y
		_camera.rotation.y = 0.0
		if is_on_floor():
			is_idle = false
			($Sophia).move()
	
	# Jumping
	if Input.is_action_pressed("move_jump") and is_on_floor():
		velocity += jump_vector
		is_idle = false
		($Sophia).jump()
	
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		velocity.y = max(-53.0, velocity.y)  # Terminal velocity (53m/s or 200km/h)
		if velocity.y < 0:
			($Sophia).fall()
	elif is_idle:
		($Sophia).idle()
	
	# Respawn (+day/night)
	if position.y < -100:
		position = Vector3(0, 70, 10)
		_world.toggle_night()
	
	# Commit!
	move_and_slide()

func _process(_delta: float) -> void:
	
	# ESC -> release mouse
	if Input.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Click -> capture mouse
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# F11
	if Input.is_action_just_pressed("ui_fullscreen"):
		if get_window().mode == Window.MODE_FULLSCREEN:
			get_window().mode = Window.MODE_MAXIMIZED
		else:
			get_window().mode = Window.MODE_FULLSCREEN
