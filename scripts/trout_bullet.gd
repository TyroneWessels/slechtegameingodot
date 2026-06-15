extends Node3D


const SPEED = 30.0
var gravity = -9.8
var velocity = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0,0, -SPEED) * delta
	velocity *= 1
	velocity.y += gravity * delta  # Apply gravity over time
	translate(velocity * delta)
	
		queue_free()
