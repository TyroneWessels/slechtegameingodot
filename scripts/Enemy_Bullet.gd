extends CharacterBody3D

var speed = 20.0
var damage = 10
var direction = Vector3.ZERO
var has_hit_something = false

func _ready():
	# Safety: if no direction was set, don't let the bullet just sit there
	if direction == Vector3.ZERO:
		queue_free()
		return

	# Lifetime timer: clean up if the bullet never exits the screen (e.g. hits floor/ceiling)
	var lifetime = Timer.new()
	lifetime.wait_time = 5.0
	lifetime.one_shot = true
	lifetime.timeout.connect(queue_free)
	add_child(lifetime)
	lifetime.start()

func _physics_process(delta):
	if has_hit_something:
		return

	velocity = direction * speed
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider and collider.is_in_group("Player"):
			has_hit_something = true

			if collider.has_method("take_damage"):
				collider.take_damage(damage)

			if is_inside_tree():
				queue_free()
			return

func _on_visible_on_screen_notifier_3d_screen_exited():
	if is_inside_tree():
		queue_free()
