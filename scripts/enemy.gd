extends CharacterBody3D

enum {
	idlePistol,
	runningPistol,
	walkingPistol,
}

var state = idlePistol

@onready var animation_player: AnimationPlayer = $AnimationPlayer
