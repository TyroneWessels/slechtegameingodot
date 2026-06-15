extends CharacterBody3D

# Player Nodes
@onready var neck: Node3D = $neck
@onready var head: Node3D = $neck/head
@onready var eyes: Node3D = $neck/head/eyes
@onready var standing_collison_shape: CollisionShape3D = $standing_collison_shape
@onready var crouching_collison_shape: CollisionShape3D = $crouching_collison_shape
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var camera_3d: Camera3D = $neck/head/eyes/Camera3D
@onready var animation_player: AnimationPlayer = $neck/head/eyes/AnimationPlayer
@onready var slingshot_anim: AnimationPlayer = $neck/head/Slingshot/Slingshot_Anim
@onready var joint_anim: AnimationPlayer = $neck/head/eyes/Camera3D/Joint_anim
@onready var geo_trout: MeshInstance3D = $neck/head/Slingshot/Geo_Trout
@onready var ray_cast_slingshot: RayCast3D = $neck/head/Slingshot/RayCast3D2
@onready var joint: Node3D = $neck/head/eyes/Camera3D/Joint
@onready var joint_lit: Node3D = $neck/head/eyes/Camera3D/Joint_lit
@onready var gpu_particles_3d: GPUParticles3D = $neck/head/eyes/Camera3D/Joint_lit/GPUParticles3D
@onready var lighter: Node3D = $neck/head/eyes/Camera3D/lighter
@onready var lighter_fire: Node3D = $neck/head/eyes/Camera3D/lighter/Lighter_fire
@onready var gpu_particles_3d2: GPUParticles3D = $neck/head/eyes/Camera3D/GPUParticles3D

# Health
const MAX_HEALTH = 100
var health = MAX_HEALTH
var hud

# Speed Variables
var current_speed = 5.0
const walking_speed = 5.0
const sprinting_speed = 8.0
const crouching_speed = 3.0

# States
var walking = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false

# Smoking
var smoking = false
var puffs = 0

# Slingshot
var ammo = 1
var bullet = load("res://scenes/trout_bullet.tscn")
var instance

# Slide
var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector = Vector2.ZERO
var slide_speed = 12.0

# Head bobbing
const head_bobbing_sprinting_speed = 22.0
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0
const head_bobbing_sprinting_intensity = 0.2
const head_bobbing_walking_intensity = 0.1
const head_bobbing_crouching_intensity = 0.05
var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0

# Movement
const jump_velocity = 4.5
var crouching_depth = -0.5
var lerp_speed = 10.0
var air_lerp_speed = 3.0
var free_look_tilt_amount = 8
var last_velocity = Vector3.ZERO

# Input
var direction = Vector3.ZERO
const mouse_sens = 0.4

func _ready():
	add_to_group("Player")
	joint.visible = false
	joint_lit.visible = false
	gpu_particles_3d2.visible = false
	lighter.visible = false
	lighter_fire.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_health(health, MAX_HEALTH)
	else:
		print("HUD not found!")

func hurt(hit_points):
	health = clamp(health - hit_points, 0, MAX_HEALTH)
	if hud:
		hud.update_health(health, MAX_HEALTH)
	if health <= 0:
		die()

func die():
	# Stop the player from running physics so it stops triggering collisions
	set_physics_process(false)
	
	# Go directly to the main engine window to force a safe reload
	var main_tree = Engine.get_main_loop() as SceneTree
	if main_tree:
		main_tree.call_deferred("reload_current_scene")

func _input(event):
	if event is InputEventMouseMotion:
		if free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-100), deg_to_rad(100))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backward")

	# Crouching
	if Input.is_action_pressed("crouch") || sliding:
		current_speed = lerp(current_speed, crouching_speed, delta * lerp_speed)
		head.position.y = lerp(head.position.y, crouching_depth, delta * lerp_speed)
		standing_collison_shape.disabled = true
		crouching_collison_shape.disabled = false
		if sprinting && input_dir != Vector2.ZERO:
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			free_looking = true
		walking = false
		sprinting = false
		crouching = true
	elif !ray_cast_3d.is_colliding():
		standing_collison_shape.disabled = false
		crouching_collison_shape.disabled = true
		head.position.y = lerp(head.position.y, 0.0, delta * lerp_speed)
		if Input.is_action_pressed("sprint"):
			current_speed = lerp(current_speed, sprinting_speed, delta * lerp_speed)
			walking = false
			sprinting = true
			crouching = false
		else:
			current_speed = lerp(current_speed, walking_speed, delta * lerp_speed)
			walking = true
			sprinting = false
			crouching = false

	# Free looking
	if Input.is_action_pressed("free_look") || sliding:
		free_looking = true
		if sliding:
			eyes.rotation.z = lerp(eyes.rotation.z, -deg_to_rad(7.0), delta * lerp_speed)
		else:
			eyes.rotation.z = -deg_to_rad(neck.rotation.y * free_look_tilt_amount)
	else:
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y, 0.0, delta * lerp_speed)
		eyes.rotation.z = lerp(eyes.rotation.z, 0.0, delta * lerp_speed)

	# Joint
	if Input.is_action_just_pressed("light_joint"):
		if !joint_anim.is_playing() and !smoking and !slingshot_anim.is_playing():
			smoking = true
			joint_anim.play("Spark_up")
		elif !joint_anim.is_playing() and smoking and !slingshot_anim.is_playing():
			if puffs < 5 and smoking:
				if !joint_anim.is_playing() or !slingshot_anim.is_playing():
					joint_anim.play("puff")
					puffs += 1
			else:
				joint_anim.play("flick_away")
				smoking = false
				puffs = 0

	# Sliding
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
			free_looking = false

	# Head bobbing
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed * delta
	elif walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_crouching_speed * delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta

	if is_on_floor() && !sliding && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index / 2) + 0.5
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y * (head_bobbing_current_intensity / 2.0), delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x * head_bobbing_current_intensity, delta * lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta * lerp_speed)

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if !ray_cast_3d.is_colliding():
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_velocity
			sliding = false
			animation_player.play("jump")

	# Landing
	if is_on_floor():
		if last_velocity.y < -10.0:
			animation_player.play("roll")
		elif last_velocity.y < -4.0:
			animation_player.play("landing")

	# Shooting
	if Input.is_action_just_pressed("shoot"):
		if !slingshot_anim.is_playing() and !joint_anim.is_playing():
			slingshot_anim.play("shoot")
			await get_tree().create_timer(0.333333).timeout
			
			# Check if the player node tree environment is still valid after the await timer
			if is_inside_tree() and ray_cast_slingshot.is_colliding():
				var hit = ray_cast_slingshot.get_collider()
				if hit and hit.has_method("take_damage"):
					hit.take_damage(20) # FIX: Set to 20 damage per shot
			
			if is_inside_tree():
				instance = bullet.instantiate()
				instance.position = ray_cast_slingshot.global_position
				instance.transform.basis = ray_cast_slingshot.global_transform.basis
				get_parent().add_child(instance)
	# Movement
	if is_on_floor():
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * air_lerp_speed)

	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
		current_speed = (slide_timer + 0.2) * slide_speed

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	last_velocity = velocity
	move_and_slide()
