extends CanvasLayer

var health_bar: ProgressBar
var health_label: Label

func _ready():
	add_to_group("hud")
	health_bar = $VBoxContainer/HealthBar
	health_label = $VBoxContainer/HealthLabel
	if health_bar == null:
		print("ERROR: HealthBar not found!")
		return
	if health_label == null:
		print("ERROR: HealthLabel not found!")
		return
	health_bar.max_value = 100
	health_bar.min_value = 0
	health_bar.value = 100
	health_bar.show_percentage = false
	health_label.text = "HP: 100 / 100"

func update_health(current: int, maximum: int):
	if health_bar:
		health_bar.value = current
	if health_label:
		health_label.text = "HP: %d / %d" % [current, maximum]
