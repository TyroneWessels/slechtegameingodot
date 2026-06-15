extends CharacterBody3D

<<<<<<< HEAD
enum { IDLE, ALERT }
=======
enum {
	IDLE,
	ALERT
}

var health = 1

>>>>>>> fe0fa6bde9c05f6b9edea6b4229654e4cbc3b043
var state = IDLE
var target: CharacterBody3D = null

const TURN_SPEED = 5.0
const MOVE_SPEED = 3.0
var health = 100

# Optimization: Using @export lets you assign this in the inspector safely
@export var bullet_scene: PackedScene = preload("res://scenes/Enemy_bullet.tscn")

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var eyes: Node3D = $Eyes
@onready var shoot_timer: Timer = $ShootTimer
@onready var animation_player_gun: AnimationPlayer = $Armature/Skeleton3D/BoneAttachment3D/Sketchfab_Scene/AnimationPlayer

func _ready():
	# Wait a single frame to make absolutely sure all child nodes exist
	await get_tree().process_frame
	
	# Only change settings if the node actually exists
	if has_node("NavigationAgent3D") and navigation_agent_3d:
		navigation_agent_3d.path_desired_distance = 0.5
		navigation_agent_3d.target_desired_distance = 2.0
	else:
		print("Warning: Enemy cannot find NavigationAgent3D node!")
		
	# Keep our path update timer
	var path_timer = Timer.new()
	path_timer.wait_time = 0.2 
	path_timer.autostart = true
	path_timer.timeout.connect(_update_path)
	add_child(path_timer)

func take_damage(amount):
	health -= amount
	print("Enemy hit! Health: ", health)
	if health <= 0:
		die()

func die():
	queue_free()

# Only updates path targets on a separate interval to prevent freezing
func _update_path():
	# Added a check: only look for the target if it actually exists in the world
	if state == ALERT and is_instance_valid(target) and target.is_inside_tree():
		navigation_agent_3d.target_position = target.global_transform.origin
		
func _on_sightrange_body_entered(body: Node3D):
	if body.is_in_group("Player"):
		state = ALERT
		target = body
		if shoot_timer.is_stopped():
			shoot_timer.start()

func _on_sightrange_body_exited(body: Node3D):
	if body == target:
		state = IDLE
		target = null
		shoot_timer.stop()

func _on_shoot_timer_timeout():
	if not is_instance_valid(target):
		shoot_timer.stop()
		return
		
	# Force immediate raycast update before checking collision
	ray_cast_3d.force_raycast_update()
	
	if ray_cast_3d.is_colliding():
		var hit = ray_cast_3d.get_collider()
<<<<<<< HEAD
		if hit and hit.is_in_group("Player"):
			var b = bullet_scene.instantiate()
			# Best practice to add child to the current scene tree root branch, not absolute root
			get_tree().current_scene.add_child(b) 
			b.global_transform.origin = eyes.global_transform.origin
			b.direction = (target.global_transform.origin - eyes.global_transform.origin).normalized()

func _physics_process(delta):
=======
		if hit.is_in_group("Player"):
			animation_player_gun.play("shoot")
			get_tree().call_group("Player", "hurt", 2)
			print("hit")

func hurt(hit_points):
	if hit_points < health:
		health -= hit_points
	else:
		health = 0
	if health == 0:
		die()

func die():
	animation_player.play("Dying")

func _process(delta):
	
>>>>>>> fe0fa6bde9c05f6b9edea6b4229654e4cbc3b043
	match state:
		IDLE:
			animation_player.play("idlePistol")
			velocity = velocity.move_toward(Vector3.ZERO, MOVE_SPEED * delta)
			move_and_slide()
			
		ALERT:
			if not is_instance_valid(target):
				state = IDLE
				return
				
			animation_player.play("runningPistol")

			# Rotate body to face player smoothly
			var target_dir = (target.global_transform.origin - global_transform.origin)
			target_dir.y = 0
			if target_dir.length_squared() > 0.001:
				target_dir = target_dir.normalized()
				var target_angle = atan2(target_dir.x, target_dir.z) + PI
				rotation.y = lerp_angle(rotation.y, target_angle, delta * TURN_SPEED)

			# Aim eyes and raycast at player
			eyes.look_at(target.global_transform.origin, Vector3.UP)
			var target_local = ray_cast_3d.to_local(target.global_transform.origin)
			ray_cast_3d.target_position = target_local

			# Movement handling via Navigation Agent
			if not navigation_agent_3d.is_navigation_finished():
				var next_pos = navigation_agent_3d.get_next_path_position()
				var move_dir = (next_pos - global_transform.origin)
				move_dir.y = 0
				move_dir = move_dir.normalized()
				velocity = move_dir * MOVE_SPEED
			else:
				velocity = Vector3.ZERO
				
			move_and_slide()
