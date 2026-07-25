extends Label

func _ready() -> void:
	get_parent().get_parent().display_message.connect(_on_display_message.bind())

func _on_display_message(message: String) -> void:
	text = message
