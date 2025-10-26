@tool
class_name GravitySphere
extends GravityRegion


var col_shape := CircleShape2D.new()

## How large the surface of the sphere should be.
@export_range(0, 1000, 1, "or_greater") var surface_radius := 200.0:
	set(r):
		surface_radius = r
		resize_collision()

func _init() -> void:
	super()
	col_shape.radius = surface_radius + falloff_start + falloff_length
	collider_node.shape = col_shape

func resize_collision() -> void:
	col_shape.radius = surface_radius + falloff_start + falloff_length
	if Engine.is_editor_hint() or (is_inside_tree() and get_tree().debug_collisions_hint):
		surface_debug_shape.points = MathLib.create_circle(surface_radius)
		fall_start_dbg.points = MathLib.create_circle(surface_radius + falloff_start)
		fall_end_dbg.points = MathLib.create_circle(surface_radius + falloff_start + falloff_length)

func get_gravity_at(global_pos: Vector2) -> Vector2:
	var local_pos := (global_pos - self.global_position)
	var gravity_dir = local_pos.normalized()
	if local_pos.length() > surface_radius:
		gravity_dir = -gravity_dir
	return gravity_dir * gravity_strength

func get_gravity_influence(global_pos: Vector2) -> float:
	var local_pos := (global_pos - self.global_position)
	var dist_to_surface = (local_pos.length() - surface_radius)
	if is_zero_approx(falloff_length):
		#print(1.0 if dist_to_surface < falloff_start else 0.0)
		return 1.0 if dist_to_surface < falloff_start else 0.0
	var influence = 1.0 - clampf(
		(dist_to_surface - falloff_start) / falloff_length,
		0.0,
		1.0
	)
	#print(influence)
	return influence
