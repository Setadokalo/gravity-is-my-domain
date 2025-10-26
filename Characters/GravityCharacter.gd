@abstract
class_name GravityCharacter
extends CharacterBody2D

var local_gravity := Vector2(0, 0)

func _ready() -> void:
	local_gravity = GravityApplicator.default_gravity

func _physics_process(delta: float) -> void:
	velocity += local_gravity * delta
	up_direction = -(local_gravity.normalized()) if local_gravity.length_squared() > 0.1 else up_direction
	global_rotation = MathLib.move_towards_angle(global_rotation, (-up_direction).angle() - (PI * 0.5), delta * 2.0)

	var input = input_dir()
	var local_velocity := velocity.rotated(-global_rotation)
	if is_on_floor() and input.is_zero_approx():
		local_velocity *= pow(0.1, delta)
	if is_on_floor():
		local_velocity.x += input.x * 300.0 * delta * 4.0
		local_velocity.x = clampf(local_velocity.x, -300.0, 300.0)
	else:
		local_velocity.x += input.x * 300.0 * delta
	if local_gravity.length() < 100.0:
		local_velocity.y += input.y * 300.0 * delta

	if is_on_floor() and desires_jump():
		local_velocity.y = -500

	velocity = local_velocity.rotated(global_rotation)
	move_and_slide()

## Requested movement direction in local space.
## Vertical movement won't be used much, I expect.
@abstract
func input_dir() -> Vector2

## Return true if a jump on this frame would be expected.
## For a character, this could include an input buffer window.
@abstract
func desires_jump() -> bool

## Called when a jump actually happens, to allow clearing input buffers.
func _on_jump() -> void:
	pass
