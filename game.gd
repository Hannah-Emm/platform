extends Node3D

@export var person_count: int = 25

var person_scene = load("res://Person.tscn")

func _ready() -> void:
	for i in range(person_count):
		var person = person_scene.instantiate()
		add_child(person)
		person.add_to_group("People")
		$CrowdSound.play()
		$PlatformSound.play()
