extends Label

@onready var timer: Timer = get_parent().get_parent().get_node("LevelTimer")

func _process(_delta: float) -> void:
	var minutes: int = int(timer.time_left / 60)
	var seconds: int = timer.time_left - (minutes * 60)
	var tenths: int = int(timer.time_left * 10) - (minutes * 600) - (seconds * 10)
	text = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2) + "." + str(tenths).pad_zeros(1)
