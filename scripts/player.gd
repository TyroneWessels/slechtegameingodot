extends CharacterBody3D

# Player Nodes
@onready var neck: Node3D = $neck
@onready var head: Node3D = $neck/head
@onready var standing_collison_shape: CollisionShape3D = $standing_collison_shape
@onready var crouching_collison_shape: CollisionShape3D = $crouching_collison_shape
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var camera_3d: Camera3D = $neck/head/Camera3D

# Speed Variables
var current_speed = 5.0

const walking_speed = 5.0
const sprinting_speed = 8.0
const crouching_speed = 3.0

#States
var walking = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false

#Slide Variables
var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector = Vector2.ZERO
var slide_speed = 10.0

# Movement Variables
const jump_velocity = 4.5

var crouching_depth = -0.5

var lerp_speed = 10.0

var free_look_tilt_amount = 8

# Input Variables
var direction = Vector3.ZERO
const mouse_sens = 0.4

# Mouse Lock
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Looking
func _input(event):
	if event is InputEventMouseMotion:
		if free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			neck.rotation.y = clamp(neck.rotation.y,deg_to_rad(-100),deg_to_rad(100))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))

func _physics_process(delta: float) -> void:
	# Getting movement input
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	# Crouching Logic
	if Input.is_action_pressed("crouch") || sliding:
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y,crouching_depth,delta*lerp_speed)
		
		standing_collison_shape.disabled = true
		crouching_collison_shape.disabled = false
		
		#Slide begin
		if sprinting && input_dir != Vector2.ZERO:
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			free_looking = true
		
		walking = false
		sprinting = false
		crouching = true
	# Head Block Check
	elif !ray_cast_3d.is_colliding():
		standing_collison_shape.disabled = false
		crouching_collison_shape.disabled = true
		
		head.position.y = lerp(head.position.y,0.0,delta*lerp_speed)
		# Sprint Logic
		if Input.is_action_pressed("sprint"):
			current_speed = sprinting_speed
			
			walking = false
			sprinting = true
			crouching = false
		else:
			current_speed = walking_speed
			
			walking = true
			sprinting = false
			crouching = false

	# Handle Free Looking
	if Input.is_action_pressed("free_look") || sliding:
		free_looking = true
		camera_3d.rotation.z = -deg_to_rad(neck.rotation.y*free_look_tilt_amount)
	else:
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y,0.0,delta*lerp_speed)
		camera_3d.rotation.z = lerp(camera_3d.rotation.z,0.0,delta*lerp_speed)
	
	#Handle Sliding
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
			free_looking = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if !ray_cast_3d.is_colliding():
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_velocity
			sliding = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x,0,slide_vector.y)).normalized()
		
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		if sliding:
			velocity.x = direction.x * (slide_timer + 0.2) * slide_speed
			velocity.z = direction.z * (slide_timer + 0.2) * slide_speed
			
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
