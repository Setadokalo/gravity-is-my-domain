## Rigid body that supports custom gravity.
class_name GravityRigidBody2D
extends RigidBody2D

func _enter_tree() -> void:
	GravityApplicator.gravity_affected_bodies.set(self, [])
func _exit_tree() -> void:
	GravityApplicator.gravity_affected_bodies.erase(self)
