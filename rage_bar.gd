extends TextureRect

func _ready() -> void:
	get_parent().get_parent().get_node("Player").rage_level.connect(_on_rage_level.bind())

func _on_rage_level(value: float) -> void:
	texture.get_gradient().set_offset(1, value)
