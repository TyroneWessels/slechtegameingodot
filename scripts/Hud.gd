extends CanvasLayer

@onready var health_bar: ProgressBar = $BoxContainer/HealthBar
@onready var health_label: Label = $BoxContainer/HealthLabel

func _ready():
	add_to_group("hud")
	health_bar.max_value = 100
	health_bar.min_value = 0
	health_bar.value = 100
	health_bar.show_percentage = false
	health_label.text = "HP: 100 / 100"

func update_health(current: int, maximum: int):
	health_bar.value = current
	health_label.text = "HP: %d / %d" % [current, maximum]
