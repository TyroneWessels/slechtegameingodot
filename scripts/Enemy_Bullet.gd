extends CharacterBody3D

var speed = 20.0
var damage = 10
var direction = Vector3.ZERO
var has_hit_something = false # 1. Added a safety switch!

func _physics_process(delta):
	# If we already hit the player, stop moving and stop checking collisions
	if has_hit_something:
		return

	velocity = direction * speed
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider.is_in_group("Player"):
			has_hit_something = true # 2. Turn on the safety switch instantly!
			
			if collider.has_method("hurt"):
				collider.hurt(damage) # 3. Only hurts you ONCE for 10 HP
				
			if is_inside_tree():
				queue_free() # 4. Safely disappear
			return 

func _on_visible_on_screen_notifier_3d_screen_exited():
	if is_inside_tree():
		queue_free()
