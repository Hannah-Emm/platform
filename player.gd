extends CharacterBody3D

signal rage_level(level: float)
signal cooldown(duration: float)
signal hit()

@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.01
@export var max_speed: float = 25.0
@export var acceleration: float = 4.0
@export var deceleration: float = 40.0
@export var dash_speed: float = 60.0
@export var max_rage_level: float = 1000.0
@export var dash_cost: float = 100.0
@export var jump_cost: float = 25.0
@export var unstuck_rage_bonus: float = 100.0
@export var max_rage_gain_speed: float = 50.0

@onready var dash_timer: Timer = $DashTimer
@onready var freeze_timer: Timer = $FreezeTimer

var alive: bool = true
var current_rage_level: float = 0.0
var current_speed: float = 0
var dashing: bool = false
var frozen: bool = false


@onready var camera: Camera3D = $Camera3D
var mouse_motion: Vector2 = Vector2()

func _process(delta: float) -> void:
	if !dashing:
		add_rage((1 - (current_speed / max_speed)) * max_rage_gain_speed * delta)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if alive and Input.is_action_just_pressed("move_jump") and is_on_floor() and use_rage(jump_cost):
			velocity.y = jump_velocity
		if !frozen:
			var input_dir := Input.get_vector("move_left", "move_right", "move_foward", "move_backward")
			var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if direction and !dashing and alive:
				if Input.is_action_just_pressed("move_dash") and use_rage(dash_cost):
					dash_timer.start()
					dashing = true
					current_speed = dash_speed
				else:
					current_speed = min(current_speed + (acceleration * delta), max_speed)
				velocity.x = direction.x * current_speed
				velocity.z = direction.z * current_speed
			elif !dashing and is_on_floor():
				current_speed = max(current_speed - (deceleration * delta), 0)
				velocity.x = move_toward(velocity.x, 0, deceleration * delta)
				velocity.z = move_toward(velocity.z, 0, deceleration * delta)

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
	if !alive:
		return
	current_rage_level = min(current_rage_level + amount, max_rage_level)
	rage_level.emit((current_rage_level / max_rage_level) * 100)

func use_rage(cost: float) -> bool:
	if current_rage_level >= cost:
		current_rage_level -= cost
		rage_level.emit((current_rage_level / max_rage_level) * 100)
		return true
	return false

func kill() -> void:
	alive = false

func reset() -> void:
	alive = true
	current_rage_level = 0
	rage_level.emit(0)

func is_alive() -> bool:
	return alive

func hit_person():
	current_speed = 0
	velocity.x = 0
	velocity.z = 0
	dashing = false
	if (freeze_timer.is_stopped() or !frozen) and alive:
		freeze_timer.start()
		cooldown.emit(freeze_timer.wait_time)
		hit.emit()
		frozen = true

func _on_hit_box_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	if !frozen and body is CharacterBody3D and body != self:
		var is_player_facing: bool = global_position.direction_to(body.global_position).dot(-global_transform.basis.z) > 0
		var is_player_moving_towards: bool = global_position.direction_to(body.global_position).dot(velocity.normalized()) > 0
		print("Hit! Player facing: ", str(is_player_facing), " moving towards: ", str(is_player_moving_towards))
		if is_player_facing or is_player_moving_towards:
			hit_person()

func _on_dash_timer_timeout() -> void:
	current_speed = max_speed
	dashing = false

func _on_freeze_timer_timeout() -> void:
	add_rage(unstuck_rage_bonus)
	frozen = false
