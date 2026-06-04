extends CharacterBody3D

enum {
	IDLE,
	ALERT
}

var state = IDLE

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ray_cast_3d: RayCast3D = $RayCast3D

func _ready():
	pass

func _process(delta):
	if ray_cast_3d.is_colliding():
		state = ALERT
	else:
		state = IDLE
	
	match state:
		IDLE:
			animation_player.play("idlePistol")
		ALERT:
			animation_player.play("runningPistol")

func _physics_process(delta):

func update_target_location(target_location):
	nav_agent.target_position = target_loc  
