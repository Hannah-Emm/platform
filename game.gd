extends Node3D

signal display_message(message: String)
signal display_temporary_message(message: String, duration: float)

@export var person_count: int = 25

@onready var level_timer: Timer = $LevelTimer
@onready var player: CharacterBody3D = $Player

var person_scene = load("res://Person.tscn")

var goal_point: Area3D

func _ready() -> void:
	reset_level()

func reset_level() -> void:
	display_message.emit("")
	get_tree().call_group("People", "queue_free")
	spawn_people()
	spawn_player()
	reset_timer()

func spawn_people() -> void:
	for i in range(person_count):
		var person = person_scene.instantiate()
		add_child(person)
		person.add_to_group("People")

func spawn_player() -> void:
	if goal_point != null:
		goal_point.body_entered.disconnect(_on_finish_body_entered.bind())

	get_tree().call_group("PlayerGoals", "hide")
	var goals = get_tree().get_nodes_in_group("PlayerGoals").duplicate()
	goals.shuffle()
	var spawn_point: Node3D = goals.pop_front()
	goal_point = goals.pop_front()
	goal_point.body_entered.connect(_on_finish_body_entered.bind())
	goal_point.show()
	display_temporary_message.emit("Your train is on the " + goal_point.get_meta("platform_color") + " platform!", 5.0)

	player.global_position = spawn_point.global_position
	player.rotation = spawn_point.rotation
	player.velocity = Vector3.ZERO
	player.reset()
	player.reset_physics_interpolation.call_deferred()

func reset_timer() -> void:
	level_timer.paused = false
	level_timer.start()

func _on_level_timer_timeout() -> void:
	display_message.emit("You lose!")
	player.kill()

func _on_finish_body_entered(body: Node3D) -> void:
	if body == player and player.is_alive():
		display_message.emit("You win!")
		level_timer.paused = true
		player.kill()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("action_reset"):
		reset_level()
