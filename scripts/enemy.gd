extends CharacterBody3D

enum {
	idlePistol,
	runningPistol,
	walkingPistol,
}

var state = idlePistol

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ray_cast_3d: RayCast3D = $RayCast3D

func _ready():
	pass

func _process(delta):
	match state:
		idlePistol:
			animation_player.play("idlePistol")
		runningPistol:
			animation_player.play("runningPistol")
		walkingPistol:
			animation_player.play("walkingPistol")
