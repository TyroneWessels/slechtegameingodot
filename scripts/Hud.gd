extends CanvasLayer

var health_bar: ProgressBar
var health_label: Label

func _ready():
	add_to_group("hud")
	for child in find_children("*", "ProgressBar", true):
		health_bar = child
	for child in find_children("*", "Label", true):
		health_label = child
	if health_bar:
		health_bar.max_value = 100
		health_bar.value = 100
		health_bar.show_percentage = false
	if health_label:
		health_label.text = "HP: 100 / 100"

func update_health(current: int, maximum: int):
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current
	if health_label:
		health_label.text = "HP: %d / %d" % [current, maximum]
