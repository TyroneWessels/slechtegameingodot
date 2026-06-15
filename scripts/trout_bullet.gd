extends Node3D

@onready var ray_cast_3d: RayCast3D = $Geo_Trout/RayCast3D2

const SPEED = 30.0
const GRAVITY = -9.8

var velocity = Vector3.ZERO

func _ready() -> void:
	# Set initial forward velocity in local space
	velocity = -transform.basis.z * SPEED

	# Lifetime fallback cleanup
	var lifetime = Timer.new()
	lifetime.wait_time = 5.0
	lifetime.one_shot = true
	lifetime.timeout.connect(queue_free)
	add_child(lifetime)
	lifetime.start()

func _physics_process(delta: float) -> void:
	# Apply gravity
	velocity.y += GRAVITY * delta

	# Move bullet
	position += velocity * delta

	# Check raycast hit
	if ray_cast_3d.is_colliding():
		var hit = ray_cast_3d.get_collider()
		print("collide")

		if hit and hit.is_in_group("Enemy"):
			if hit.has_method("take_damage"):
				hit.take_damage(2)  # Only damages the enemy we actually hit

		queue_free()

func _on_visible_on_screen_notifier_3d_screen_exited():
	queue_free()
