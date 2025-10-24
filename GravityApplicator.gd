## Global script responsible for applying gravity to rigidbodies
class_name GravityApplicatorCls
extends Node

var gravity_affected_bodies: Dictionary[RigidBody2D, Array] = {}

func _init() -> void:
	pass

func _process(_delta: float) -> void:
	var real_gravity: Vector2 = PhysicsServer2D.area_get_param(
		get_viewport().find_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY
	) * PhysicsServer2D.area_get_param(
		get_viewport().find_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR
	)

	for body: RigidBody2D in gravity_affected_bodies:
		# Calculate combined gravity of all regions
		# Influence starts from the highest priority areas and goes downwards
		# If any region has 1.0 influence, it stops there - otherwise,
		# we keep going and apply the rest of the regions as a fraction of
		# the not-influenced fraction of gravity. Similar to overlaying
		# transparent objects under each other
		var total_influence := 0.0
		var combined_gravity := Vector2.ZERO
		var regions: Array = gravity_affected_bodies[body]
		regions.sort_custom(func(a, b):
			return a.priority > b.priority
		)
		for region: GravityRegion in regions:
			var r_infl := region.get_gravity_influence(body.global_position)
			# effective influence is a fraction of the currently un-influenced ratio
			# makes multiple fading edges overlapping behave consistently
			var er_infl = (1.0 - total_influence) * r_infl
			var r_vec := region.get_gravity_at(body.global_position)
			print(er_infl, " | ", r_infl, " | ", r_vec.length())
			combined_gravity += r_vec * er_infl
			total_influence += er_infl
		# whatever influence is not provided by custom gravity areas
		# is provided by the world
		var world_grav_infl := 1.0 - total_influence
		combined_gravity += real_gravity * world_grav_infl
		# Apply small linear damping when in gravity regions, helps with jankiness around switching directions
		body.linear_damp = lerp(0.0, 0.1, total_influence)
		body.apply_central_force(combined_gravity)
		# Debug visualization
		if body.has_node("GravityDebug"):
			body.get_node("GravityDebug").points = [Vector2(0, 0), body.to_local(body.global_position + combined_gravity * 0.2)]


## Add a given [GravityRegion] to the list of regions affecting a given [param body].
func add_region_to(body: RigidBody2D, region: GravityRegion) -> void:
	if not gravity_affected_bodies.has(body):
		gravity_affected_bodies.set(body, [])
	gravity_affected_bodies[body].push_back(region)

## Removes a [GravityRegion] from the list of regions affecting a [param body].
func remove_region_from(body: RigidBody2D, region: GravityRegion) -> void:
	if not gravity_affected_bodies.has(body):
		push_error("Gravity Body was not in gravity_affected_bodies")
		return
	gravity_affected_bodies[body].erase(region)
