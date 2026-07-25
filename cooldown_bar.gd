extends ProgressBar

var current_cooldown: float
var remaining_cooldown: float

func _ready() -> void:
	get_parent().get_parent().get_node("Player").cooldown.connect(_on_cooldown.bind())
	hide()

func _process(delta: float) -> void:
	if remaining_cooldown > 0:
		remaining_cooldown = max(remaining_cooldown - delta, 0)
		value = (remaining_cooldown / current_cooldown) * 100
	elif remaining_cooldown == 0:
		current_cooldown = -1
		remaining_cooldown = -1
		hide()

func _on_cooldown(duration: float) -> void:
	current_cooldown = duration
	remaining_cooldown = duration
	show()
