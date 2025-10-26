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


## How far above the surface gravity should begin to fall off.
@export_range(0, 1000, 1, "or_greater") var falloff_start := 50.0:
	set(l):
		falloff_start = l
		resize_collision()

## How long of a distance for gravity to smoothly fall off after
## [property falloff_start] units above [property surface_radius].
@export_range(0, 1000, 1, "or_greater") var falloff_length := 20.0:
	set(l):
		falloff_length = l
		resize_collision()


## Unimplemented
@export
var enabled: bool = true
## Priority of this GravityRegion. Higher priority regions apply first.
@export
var priority: int = 0
## How fast in `px/s` gravity is in this region.
@export
var gravity_strength: float = 300

## Controls visibility of the CollisionShape2D for this gravity body. Visually noisy,
## and doesn't tell much of the actual gravity influence (it's just the bounds where
## gravity from this region is considered), so it defaults to hidden.
@export
var debug_show_collider := false:
	set(v):
		debug_show_collider = v
		collider_node.visible = v

var gravity_area: Area2D

var collider_node := CollisionShape2D.new()

# Debugging shapes for visualizing gravity area
var surface_debug_shape := Line2D.new()
var fall_start_dbg := Line2D.new()
var fall_end_dbg := Line2D.new()

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

	collider_node.visible = debug_show_collider
	
	gravity_area.add_child(collider_node)
	add_child(gravity_area)

func _enter_tree() -> void:
	if Engine.is_editor_hint() or get_tree().debug_collisions_hint:
		surface_debug_shape.default_color = Color(1, 0.627, 0.2, 1)
		surface_debug_shape.width = 1.0
		surface_debug_shape.closed = true
		add_child(surface_debug_shape)
		fall_end_dbg.default_color = Color(1, 0.294, 0.2, 1)
		fall_end_dbg.width = 1.0
		fall_end_dbg.closed = true
		add_child(fall_end_dbg)

		fall_start_dbg.default_color = Color(0.2, 1, 0.2, 1)
		fall_start_dbg.width = 1.0
		fall_start_dbg.closed = true
		add_child(fall_start_dbg)
		resize_collision()

func _on_body_entered(body: Node2D) -> void:
	print(body)
	if body is RigidBody2D:
		GravityApplicator.add_region_to_rigid(body, self)
	elif body is GravityCharacter:
		GravityApplicator.add_region_to_char(body, self)
	else:
		print("Not a grb2")

func _on_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		GravityApplicator.remove_region_from_rigid(body, self)
	elif body is GravityCharacter:
		GravityApplicator.remove_region_from_char(body, self)

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

@abstract
func resize_collision() -> void
