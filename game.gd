extends Node3D

signal display_message(message: String)

@export var person_count: int = 25

@onready var level_timer: Timer = $LevelTimer
@onready var player: CharacterBody3D = $Player

var person_scene = load("res://Person.tscn")

func _ready() -> void:
	for i in range(person_count):
		var person = person_scene.instantiate()
		add_child(person)
		person.add_to_group("People")

func _on_level_timer_timeout() -> void:
	display_message.emit("You lose!")
	player.kill()


func _on_finish_body_entered(body: Node3D) -> void:
	if body == player:
		display_message.emit("You win!")
		level_timer.paused = true
		player.kill()
