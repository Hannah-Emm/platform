extends CharacterBody3D

signal rage_level(level: float)
signal hit()

@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.01
@export var max_speed: float = 5.0
@export var acceleration: float = 5.0
@export var deceleration: float = 5.0
@export var dash_speed: float = 60.0
@export var max_rage_level: float = 1000.0
@export var dash_cost: float = 100.0
@export var jump_cost: float = 25.0
@export var unstuck_rage_bonus: float = 100.0

@onready var dash_timer: Timer = $DashTimer
@onready var freeze_timer: Timer = $FreezeTimer

var current_rage_level: float = 0.0
var current_speed: float = 0
var is_dashing: bool = false
var is_frozen: bool = false


@onready var camera: Camera3D = $Camera3D
var mouse_motion: Vector2 = Vector2()

func _process(delta: float) -> void:
	if velocity.x == 0 and velocity.z == 0:
		add_rage(10 * delta)
	else:
		add_rage(1 * delta)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_just_pressed("move_jump") and is_on_floor() and use_rage(jump_cost):
			velocity.y = jump_velocity
		if !is_frozen:
			var input_dir := Input.get_vector("move_left", "move_right", "move_foward", "move_backward")
			var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if direction and !is_dashing:
				if Input.is_action_just_pressed("move_dash") and use_rage(dash_cost):
					dash_timer.start()
					is_dashing = true
					current_speed = dash_speed
				else:
					current_speed = min(current_speed + acceleration, max_speed)
				velocity.x = direction.x * current_speed
				velocity.z = direction.z * current_speed
			elif !is_dashing:
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

func add_rage(amount: float) -> void:
	current_rage_level = min(current_rage_level + amount, max_rage_level)
	rage_level.emit(current_rage_level / max_rage_level)

func use_rage(cost: float) -> bool:
	if current_rage_level >= cost:
		current_rage_level -= cost
		rage_level.emit(current_rage_level / max_rage_level)
		return true
	return false

func hit_person():
	current_speed = 0
	velocity.x = 0
	velocity.z = 0
	is_dashing = false
	if freeze_timer.is_stopped() or !is_frozen:
		freeze_timer.start()
		hit.emit()
		is_frozen = true

func _on_hit_box_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	if !is_frozen and body is CharacterBody3D and body != self:
		var is_player_facing: bool = global_position.direction_to(body.global_position).dot(-global_transform.basis.z) > 0
		var is_player_moving_towards: bool = global_position.direction_to(body.global_position).dot(velocity.normalized()) > 0
		print("Hit! Player facing: ", str(is_player_facing), " moving towards: ", str(is_player_moving_towards))
		if is_player_facing or is_player_moving_towards:
			hit_person()

func _on_dash_timer_timeout() -> void:
	current_speed = max_speed
	is_dashing = false

func _on_freeze_timer_timeout() -> void:
	add_rage(unstuck_rage_bonus)
	is_frozen = false
