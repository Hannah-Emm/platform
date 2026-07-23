extends CharacterBody3D

@export var movement_speed: float = 2.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var goal_1: PathFollow3D = get_parent().get_node("Goal1").get_node("Path")
@onready var goal_2: PathFollow3D = get_parent().get_node("Goal2").get_node("Path")
@onready var goals: Array[PathFollow3D] = [goal_1, goal_2]
var current_goal_index: int = 0

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
	navigate_to_goal()

func navigate_to_next_goal() -> void:
	current_goal_index += 1
	if current_goal_index >= goals.size():
		current_goal_index = 0
	navigate_to_goal()

func navigate_to_goal() -> void:
	var current_goal: PathFollow3D = goals[current_goal_index]
	current_goal.progress_ratio = rng.randf()
	navigation_agent.set_target_position(current_goal.global_position)

func _physics_process(_delta) -> void:
	if navigation_agent.is_navigation_finished():
		navigate_to_next_goal()

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	navigation_agent.set_velocity(current_agent_position.direction_to(next_path_position) * movement_speed)

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()
