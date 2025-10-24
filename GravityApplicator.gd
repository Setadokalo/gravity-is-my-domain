## Global script responsible for applying gravity to rigidbodies
extends Node

var gravity_affected_bodies: Dictionary[GravityRigidBody2D, Array] = {}

func _init() -> void:
	pass

func _process(delta: float) -> void:
	var real_gravity: Vector2 = PhysicsServer2D.area_get_param(
		get_viewport().find_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY
	) * PhysicsServer2D.area_get_param(
		get_viewport().find_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR
	)


	for body: GravityRigidBody2D in gravity_affected_bodies:
		var total_influence := 0.0
		var combined_gravity := Vector2.ZERO
		var regions: Array = gravity_affected_bodies[body]
		regions.sort_custom(func(a, b):
			return a.priority > b.priority
		)
		for region: GravityRegion in regions:
			var r_infl := region.get_gravity_influence(body.global_position)
			var r_vec := region.get_gravity_at(body.global_position)
			combined_gravity += r_vec * r_infl * (1.0 - total_influence)
			print((1.0 - total_influence) * r_infl, " | ", r_infl, " | ", r_vec.length())
			total_influence += (1.0 - total_influence) * r_infl
		# whatever influence is not provided by custom gravity areas
		# is provided by the world
		var world_grav_infl := 1.0 - total_influence
		combined_gravity += real_gravity * world_grav_infl
		if body.has_node("GravityDebug"):
			body.get_node("GravityDebug").points = [Vector2(0, 0), body.to_local(body.global_position + combined_gravity * 0.2)]
		body.linear_damp = lerp(0.0, 0.1, total_influence)
		body.apply_central_force(combined_gravity)

func add_region_to(body: GravityRigidBody2D, region: GravityRegion) -> void:
	if not gravity_affected_bodies.has(body):
		push_error("Gravity Body was not in gravity_affected_bodies")
		return
	gravity_affected_bodies[body].push_back(region)

func remove_region_from(body: GravityRigidBody2D, region: GravityRegion) -> void:
	if not gravity_affected_bodies.has(body):
		push_error("Gravity Body was not in gravity_affected_bodies")
		return
	gravity_affected_bodies[body].erase(region)
