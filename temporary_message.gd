extends Label

var timer: SceneTreeTimer

func _ready() -> void:
	get_parent().get_parent().display_temporary_message.connect(_on_display_temporary_message.bind())

func _on_display_temporary_message(message: String, duration: float) -> void:
	if timer != null:
		timer.timeout.disconnect(_on_timer_timeout.bind())
	text = message
	timer = get_tree().create_timer(duration)
	timer.timeout.connect(_on_timer_timeout.bind())

func _on_timer_timeout() -> void:
	text = ""
