## Global script responsible for applying gravity to rigidbodies
class_name GravityApplicatorCls
extends Node

var gravity_affected_rigids: Dictionary[RigidBody2D, Array] = {}
var gravity_affected_chars: Dictionary[GravityCharacter, Array] = {}

var default_gravity: Vector2

var player_grav_influence := 0.0

func _enter_tree() -> void:
	default_gravity = PhysicsServer2D.area_get_param(
		get_viewport().find_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY
	) * PhysicsServer2D.area_get_param(
		get_viewport().find_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR
	)

func _process(_delta: float) -> void:

	for body: RigidBody2D in gravity_affected_rigids:

		var regions: Array = gravity_affected_rigids[body]
		regions.sort_custom(func(a, b):
			return a.priority > b.priority
		)
		var gravity = calculate_gravity(body.global_position, regions)
		# Apply small linear damping when in gravity regions, helps with jankiness around switching directions
		body.linear_damp = lerp(0.0, 0.1, gravity.influence)
		body.apply_central_force(gravity.gravity)
		# Debug visualization
		if body.has_node("GravityDebug"):
			body.get_node("GravityDebug").points = [Vector2(0, 0), body.to_local(body.global_position + gravity.gravity * 0.2)]
	for body: GravityCharacter in gravity_affected_chars:
		var regions: Array = gravity_affected_chars[body]
		regions.sort_custom(func(a, b):
			return a.priority > b.priority
		)
		var gravity = calculate_gravity(body.global_position, regions)
		if body is PlayerCharacter:
			player_grav_influence = gravity.influence
		body.local_gravity = gravity.gravity


## Add a given [GravityRegion] to the list of regions affecting a given [param body].
func add_region_to_rigid(body: RigidBody2D, region: GravityRegion) -> void:
	if not gravity_affected_rigids.has(body):
		gravity_affected_rigids.set(body, [])
	gravity_affected_rigids[body].push_back(region)

## Add a given [GravityRegion] to the list of regions affecting a given [param body].
func add_region_to_char(body: GravityCharacter, region: GravityRegion) -> void:
	if not gravity_affected_chars.has(body):
		gravity_affected_chars.set(body, [])
	gravity_affected_chars[body].push_back(region)

## Removes a [GravityRegion] from the list of regions affecting a [param body].
func remove_region_from_rigid(body: RigidBody2D, region: GravityRegion) -> void:
	if not gravity_affected_rigids.has(body):
		push_error("Gravity Body was not in gravity_affected_rigids")
		return
	gravity_affected_rigids[body].erase(region)

## Removes a [GravityRegion] from the list of regions affecting a [param body].
func remove_region_from_char(body: GravityCharacter, region: GravityRegion) -> void:
	if not gravity_affected_rigids.has(body):
		push_error("Gravity Body was not in gravity_affected_rigids")
		return
	gravity_affected_chars[body].erase(region)

func calculate_gravity(body_pos: Vector2, regions: Array) -> Dictionary:
	# Calculate combined gravity of all regions
	# Influence starts from the highest priority areas and goes downwards
	# If any region has 1.0 influence, it stops there - otherwise,
	# we keep going and apply the rest of the regions as a fraction of
	# the not-influenced fraction of gravity. Similar to overlaying
	# transparent objects under each other
	var total_influence := 0.0
	var combined_gravity := Vector2.ZERO
	for region: GravityRegion in regions:
		var r_infl := region.get_gravity_influence(body_pos)
		# effective influence is a fraction of the currently un-influenced ratio
		# makes multiple fading edges overlapping behave consistently
		var er_infl = (1.0 - total_influence) * r_infl
		var r_vec := region.get_gravity_at(body_pos)
		# print(er_infl, " | ", r_infl, " | ", r_vec.length())
		combined_gravity += r_vec * er_infl
		total_influence += er_infl
	# whatever influence is not provided by custom gravity areas
	# is provided by the world
	var world_grav_infl := 1.0 - total_influence
	combined_gravity += default_gravity * world_grav_infl
	return {gravity = combined_gravity, influence = total_influence}
