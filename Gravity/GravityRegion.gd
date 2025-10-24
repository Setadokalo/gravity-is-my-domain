@tool
@abstract
class_name GravityRegion
extends Node2D

const GRAVITY_LAYER := -2147483648

@export
var enabled: bool = true
@export
var priority: int = 0
@export
var gravity_strength: float = 300

var gravity_area: Area2D

var _rigids_in_field: Array[RigidBody2D]

func _init() -> void:
	gravity_area = Area2D.new()
	gravity_area.collision_layer = GRAVITY_LAYER
	gravity_area.collision_mask = GRAVITY_LAYER
	gravity_area.body_entered.connect(_on_body_entered)
	gravity_area.body_exited.connect(_on_body_exited)
	gravity_area.gravity_space_override = Area2D.SPACE_OVERRIDE_REPLACE
	gravity_area.gravity = 0
	gravity_area.linear_damp = 0.0
	gravity_area.linear_damp_space_override = Area2D.SPACE_OVERRIDE_REPLACE
	add_child(gravity_area)

func _on_body_entered(body: Node2D) -> void:
	print(body)
	if body is GravityRigidBody2D:
		_rigids_in_field.push_back(body)
		GravityApplicator.add_region_to(body, self)
	else:
		print("Not a grb2")

func _on_body_exited(body: Node2D) -> void:
	if body in _rigids_in_field:
		_rigids_in_field.erase(body)
		GravityApplicator.remove_region_from(body, self)

@abstract
func get_gravity_at(global_pos: Vector2) -> Vector2

@abstract
func get_gravity_influence(global_pos: Vector2) -> float
