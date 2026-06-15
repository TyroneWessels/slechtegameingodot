extends CharacterBody3D

var speed = 20.0
var damage = 10
var direction = Vector3.ZERO
var has_hit_something = false

func _ready():
	var lifetime = Timer.new()
	lifetime.wait_time = 5.0
	lifetime.one_shot = true
	lifetime.timeout.connect(queue_free)
	add_child(lifetime)
	lifetime.start()

func _physics_process(delta):
	if has_hit_something:
		return
	if direction == Vector3.ZERO:
		return
	velocity = direction * speed
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("Player"):
			has_hit_something = true
			collider.hurt(damage)
			queue_free()
			return

func _on_visible_on_screen_notifier_3d_screen_exited():
	if is_inside_tree():
		queue_free()
