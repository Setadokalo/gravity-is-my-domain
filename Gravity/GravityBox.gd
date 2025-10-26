@tool
class_name GravityBox
extends GravityRegion


var col_shape := RectangleShape2D.new()

## How big the box should be.
@export_custom(PROPERTY_HINT_RANGE, "0,1000,1,or_greater") var surface_size := Vector2(400.0, 400.0):
	set(s):
		surface_size = s
		resize_collision()

func _init() -> void:
	super()
	col_shape.size = surface_size + Vector2(falloff_start + falloff_length, falloff_start + falloff_length) * 2.0
	collider_node.shape = col_shape

func resize_collision() -> void:
	col_shape.size = surface_size + Vector2(falloff_start + falloff_length, falloff_start + falloff_length) * 2.0
	if Engine.is_editor_hint() or (is_inside_tree() and get_tree().debug_collisions_hint):
		surface_debug_shape.points = MathLib.create_box(surface_size)
		fall_end_dbg.points = MathLib.create_rounded_box(
			surface_size + Vector2(falloff_start + falloff_length, falloff_start + falloff_length) * 2.0,
			falloff_start + falloff_length
		)
		fall_start_dbg.points = MathLib.create_rounded_box(
			surface_size + Vector2(falloff_start, falloff_start) * 2.0,
			falloff_start
		)

func get_gravity_at(global_pos: Vector2) -> Vector2:
	var local_pos := to_local(global_pos)
	return -closest_rect_side_normal(local_pos, surface_size) * gravity_strength

func get_gravity_influence(global_pos: Vector2) -> float:
	var local_pos := to_local(global_pos)
	var half := surface_size / 2
	var dx := absf(local_pos.x) - half.x
	var dy := absf(local_pos.y) - half.y

	if dx < 0 and dy < 0:
		return 1.0
	if dx < 0:
		return 1.0 - clampf((dy - falloff_start) / falloff_length, 0.0, 1.0)
	if dy < 0:
		return 1.0 - clampf((dx - falloff_start) / falloff_length, 0.0, 1.0)
	return 1.0 - clamp(((local_pos.abs() - half).length() - falloff_start) / falloff_length, 0.0, 1.0)

func closest_rect_side_normal(point: Vector2, rect_size: Vector2) -> Vector2:
	var half := rect_size * 0.5

	# Signed distance from surface of rectangle on each axis
	var dx := absf(point.x) - half.x
	var dy := absf(point.y) - half.y

	# If both are <0, we're inside the rectangle
	# no smoothing behavior applies
	if dx <= 0 and dy <= 0:
		# If we're closer to the Y-axis surface than the X-axis
		if dx > dy:
			# TODO: Should interior gravity push towards the surface?
			return Vector2(0, 1) if point.y < 0 else Vector2(0, -1)
		else:
			return Vector2(1, 0) if point.x < 0 else Vector2(-1, 0)

	# Outside the rectangle → blend corner normals
	var nx := 0.0
	var ny := 0.0

	if dx > 0:
		nx = sign(point.x) * dx
	if dy > 0:
		ny = sign(point.y) * dy

	return Vector2(nx, ny).normalized()