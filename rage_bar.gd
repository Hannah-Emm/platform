extends ProgressBar

func _ready() -> void:
	get_parent().get_parent().get_node("Player").rage_level.connect(_on_rage_level.bind())

func _on_rage_level(new_value: float) -> void:
	value = new_value
