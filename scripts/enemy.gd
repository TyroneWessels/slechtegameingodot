extends CharacterBody3D

enum {
	IDLE,
	ALERT
}

var state = IDLE

var target

const TURN_SPEED = 2

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var eyes: Node3D = $Eyes
@onready var shoot_timer: Timer = $ShootTimer

func _ready():
	pass

func _on_sightrange_body_entered(body: CharacterBody3D):
	if body.is_in_group("Player"):
		state = ALERT
		target = body
		shoot_timer.start()

func _on_sightrange_body_exited(body: CharacterBody3D):
	state = IDLE
	shoot_timer.stop()

func _on_shoot_timer_timeout():
	if ray_cast_3d.is_colliding():
		var hit = ray_cast_3d.get_collider()
		if hit.is_in_group("Player"):
			get_tree().call_group("Player", "hurt", 2)
			print("hit")
	
func _process(delta):
	
	match state:
		IDLE:
			animation_player.play("idlePistol")
		ALERT:
			animation_player.play("runningPistol")
			eyes.look_at(target.global_transform.origin, Vector3.UP)
			rotate_y(deg_to_rad(eyes.rotation.y * TURN_SPEED))
