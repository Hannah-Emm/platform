extends CharacterBody3D

var movement_speed: float = 2.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	# Make sure to not await during _ready.
	actor_setup.call_deferred()

func actor_setup() -> void:
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_random_movement_target()

func set_random_movement_target() -> void:
	var movement_target: Vector3 = Vector3(rng.randf_range(-5, 5), 0.0, rng.randf_range(-5, 5))
	navigation_agent.set_target_position(movement_target)

func _physics_process(_delta) -> void:
	if navigation_agent.is_navigation_finished():
		set_random_movement_target()

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	velocity = current_agent_position.direction_to(next_path_position) * movement_speed

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	navigation_agent.velocity = safe_velocity
	move_and_slide()
