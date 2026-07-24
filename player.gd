extends CharacterBody3D


#@export var movement_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.01
@export var max_speed: float = 5.0
@export var acceleration: float = 5.0
@export var deceleration: float = 5.0
@export var dash_speed: float = 60.0
var current_speed: float = 0
var is_dashing: bool = false
signal hit

@onready var camera: Camera3D = $Camera3D
var mouse_motion: Vector2 = Vector2()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Handle jump.
		if Input.is_action_just_pressed("move_jump") and is_on_floor():
			velocity.y = jump_velocity

		# Get the input direction and handle the movement/deceleration.
		var input_dir := Input.get_vector("move_left", "move_right", "move_foward", "move_backward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction and !is_dashing:
			#velocity.x = direction.x * movement_speed
			#velocity.z = direction.z * movement_speed
			if Input.is_action_just_pressed("move_dash"):
				$DashTimer.start()
				is_dashing = true
				print("dash start")
				current_speed = dash_speed
			elif $DashTimer.is_stopped():
				current_speed = min(current_speed + acceleration, max_speed)
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		elif !is_dashing:
			#velocity.x = move_toward(velocity.x, 0, movement_speed)
			#velocity.z = move_toward(velocity.z, 0, movement_speed)
			current_speed = max(current_speed - deceleration, 0)
			velocity.x = move_toward(velocity.x, 0, deceleration)
			velocity.z = move_toward(velocity.z, 0, deceleration)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and Input.is_action_just_pressed("action_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clampf(camera.rotation.x, -deg_to_rad(70), deg_to_rad(70))

func hit_person():
	hit.emit()
	current_speed = 0
	is_dashing = false

func _on_hit_box_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body is CharacterBody3D and body != self:
		hit_person()
		print("hit")

func _on_dash_timer_timeout() -> void:
	current_speed = max_speed
	is_dashing = false
	print("dash stop")
