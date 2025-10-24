## A 2D Area with extensible customized gravity.
## Multiple GravityRegions can affect a [RigidBody2D] at once.
## This is the abstract class - subclasses must provide
## logic for [method get_gravity_at] and [method get_gravity_influence].
@tool
@abstract
class_name GravityRegion
extends Node2D

## Layer for [GravityRegion]s to filter for.
## [RigidBody2D]s that are not on this layer
## will not get customized gravity.
const GRAVITY_LAYER := -2147483648

## Unimplemented
@export
var enabled: bool = true
## Priority of this GravityRegion. Higher priority regions apply first.
@export
var priority: int = 0
## How fast in `px/s` gravity is in this region.
@export
var gravity_strength: float = 300

var gravity_area: Area2D

var _rigids_in_field: Array[RigidBody2D]

func _init() -> void:
	# Set up gravity area to interact on the GRAVITY_LAYER,
	# trigger the _entered and _exited handlers,
	# and disable the default gravity/linear damping
	# for bodies that enter it so they can instead
	# be applied by GravityApplicator.
	gravity_area = Area2D.new()
	gravity_area.collision_layer = 0
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
	if body is RigidBody2D:
		_rigids_in_field.push_back(body)
		GravityApplicator.add_region_to(body, self)
	else:
		print("Not a grb2")

func _on_body_exited(body: Node2D) -> void:
	if body in _rigids_in_field:
		_rigids_in_field.erase(body)
		GravityApplicator.remove_region_from(body, self)

## Get the gravity vector at a given position in global space.
## The returned vector is always of [member gravity_strength] length and
## does not consider [method get_gravity_influence] - it is 
## [GravityApplicatorCls]'s responsibility to scale down this gravity.
@abstract
func get_gravity_at(global_pos: Vector2) -> Vector2

## Returns the influence this [GravityApplicatorCls] should have at the
## given position in global space. The return value should be between 0 and 1,
## with 0 indicating no influence at all.
@abstract
func get_gravity_influence(global_pos: Vector2) -> float
