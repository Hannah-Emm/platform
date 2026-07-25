extends CharacterBody3D

@export var min_movement_speed: float = 2.0
@export var max_movement_speed: float = 15.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
var goal_position: Vector3
var reset: bool = false
var movement_speed: float


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
	reset = true

func start_new_goal() -> void:
	var goals: Array[Node] = get_tree().get_nodes_in_group("Goals").duplicate()
	goals.shuffle()
	var spawn_point: Path3D = goals.pop_front()
	var spawn_point_path: PathFollow3D = spawn_point.get_node("Path")
	spawn_point_path.progress_ratio = rng.randf()


	var goal: Path3D = goals.pop_front()
	var goal_path: PathFollow3D = goal.get_node("Path")
	goal_path.progress_ratio = rng.randf()
	goal_position = goal_path.global_position

	#global_position.x = spawn_point_path.global_position.x
	#global_position.z = spawn_point_path.global_position.z
	global_position = spawn_point_path.global_position
	velocity = Vector3.ZERO
	reset_physics_interpolation.call_deferred()
	navigation_agent.set_target_position.call_deferred(goal_position)

	movement_speed = rng.randf_range(min_movement_speed, max_movement_speed)

	reset = false

func _physics_process(_delta) -> void:
	if reset:
		start_new_goal()
		return

	if navigation_agent.is_navigation_finished():
		reset = true
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	navigation_agent.set_velocity(global_position.direction_to(next_path_position) * movement_speed)

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()
